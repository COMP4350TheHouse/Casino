# This class handles the logic for the roulette page
class RouletteController < ApplicationController
  Rails.cache.write('winning_num', rand(0..36))

  def index
    puts 'A gambler has entered the roulette lobby'
  end

  # Get the randomly generated winning number
  def winning_num_request
    winning_num = Rails.cache.read('winning_num')
    render json: { winning_num: winning_num }, status: :ok
  end

  # Place a bet based on the cell the user selected
  def submit_roulette_bet
    user = Current.session.user
    amount = params[:amount].to_f
    bet_id = params[:bet_id]

    # Return invalid bet if user has insufficient balance
    return render json: { balance: user.balance, valid_bet: false }, status: :ok if insufficient_balance?(user, amount)

    bet = create_and_save_bet(user, amount, bet_id)

    deduct_user_balance(user, bet.amount)

    render json: { balance: user.balance, valid_bet: true }, status: :ok
  end

  # Check if the user has a valid balance before betting
  def insufficient_balance?(user, amount)
    user.balance < amount
  end

  # Create and save the bet under the given user
  def create_and_save_bet(user, amount, bet_id)
    bet = create_bet(user, amount, bet_id)
    bet.save
    bet
  end

  # Remove the bet amount from the users
  def deduct_user_balance(user, amount)
    return unless amount <= user.balance

    user.balance -= amount
    user.save
  end

  # Find the winning number, then payout bets
  def payout_bets
    winning_number = params[:winning_num].to_i
    user = Current.session.user

    bets = Bet.where(user_id: user.id)
    total_winnings = calculate_total_winnings(bets, winning_number)

    update_user_balance(user, total_winnings)
    clear_bets(user)
    reroll_winning_number

    render json: { balance: user.balance }, status: :ok
  end

  # Get the currently placed bets and return them so that the frontend can place chips in their cells
  def placed_chips_request
    bets = Bet.all.includes(:user)

    chips = bets.map do |bet|
      { bet_id: bet.bet_id, amount: bet.amount }
    end

    render json: chips
  end

  private

  # Create a bet on a roulette cell that will be stored
  def create_bet(user, amount, bet_id)
    puts "Roulette Bet received - [ID: #{bet_id}, Amount: $#{amount}]"
    Bet.new(user: user, amount: amount, bet_id: bet_id)
  end

  def calculate_total_winnings(bets, winning_number)
    total_winnings = 0
    bets.each do |bet|
      payout_multiplier = get_payout_multiplier(bet.bet_id.round, winning_number)
      if payout_multiplier.positive?
        winnings = bet.amount * payout_multiplier
        total_winnings += winnings
      end
    end

    total_winnings
  end

  def get_payout_multiplier(bet_id, winning_number)
    PayoutCalculator.new(bet_id, winning_number).calculate
  end

  def update_user_balance(user, winnings)
    user.balance += winnings
    user.save
  end

  def clear_bets(user)
    Bet.where(user_id: user.id).destroy_all
  end

  def reroll_winning_number
    Rails.cache.write('winning_num', rand(0..36))
  end
end
