# Controller for Horse Race Betting Game
class HorseRaceController < ApplicationController
  def initialize
    super
    @debug = false
  end

  def race
    @race_time_after_finish = 3000 # Wait 3s after the race is done
    @race_time = (Horse.maximum(:speed) * 1000) + @race_time_after_finish
  end

  def betting; end

  # Race is over, pay the money to winning wagers
  def resolve_race
    payout_wagers

    # Remove random horses every now and again to keep things fresh
    Horse.remove_random_horses

    Horse.create_new_horse

    redirect_to horse_race_betting_path
  end

  # Pay winning wagers then delete them all for the next race
  def payout_wagers
    user = Current.session.user
    winners = Horse.order(:speed).limit(3) # Get 1st, 2nd & 3rd place horses

    # Payout winning wagers
    winners.each.with_index(1) do |winner, place|
      Wager.where(horse_id: winner.id, user_id: user.id).select { |wager| wager.hits? place }.each(&:fufill)
    end

    Wager.where(user_id: user.id).destroy_all # Remove all wagers fufilled or otherwise
  end

  def submit_bet
    wager = create_wager(params)
    wager.save # add wager to database

    Current.session.user.balance -= wager.amount # remove money from the user's bankaccount
    Current.session.user.save # update user

    redirect_to horse_race_betting_path
  end

  def create_wager(params)
    user   = Current.session.user
    horse  = Horse.find(params[:horse])
    kind   = params[:kind].to_s
    amount = params[:amount].to_f
    puts "#{kind.to_s.capitalize} Bet of $#{format('%.2f', amount)} on '#{horse.name}'"

    Wager.new(user: user, horse: horse, amount: amount, kind: kind)
  end

  def debug_skip_to_race
    redirect_to horse_race_race_path
  end
end
