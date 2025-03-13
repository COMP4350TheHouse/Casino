# Controller for Horse Race Betting Game
class HorseRaceController < ApplicationController
  def initialize
    super
    @debug = false
    @freeze_bets = 70 # The furthest horse is 70% of the way across the screen we can no longer accept bets
  end

  def index; end

  def accepting_bets?
    Horse.all.all? { |horse| horse.position < @freeze_bets }
  end

  def restart_race
    Horse.update_all(position: 0)
    redirect_to horse_race_index_path
  end

  def submit_bet # rubocop:disable Metrics/AbcSize
    wager = create_wager(params)

    logger.warn "Submit Bet"

    if Current.session.user.balance > wager.amount && accepting_bets?
      wager.save # add wager to database

      Current.session.user.balance -= wager.amount # remove money from the user's bankaccount
      Current.session.user.save # update user
    end

    # render json: { balance: Current.session.user.balance, valid_bet: true }, status: :ok
    redirect_to horse_race_index_path
  end

  def create_wager(params)
    user   = Current.session.user
    horse  = Horse.find(params[:horse])
    kind   = params[:kind].to_s
    amount = params[:amount].to_f
    puts "#{kind.to_s.capitalize} Bet of $#{format('%.2f', amount)} on '#{horse.name}'"

    Wager.new(user: user, horse: horse, amount: amount, kind: kind)
  end
end
