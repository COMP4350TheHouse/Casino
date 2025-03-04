# This class handles the logic for the lobby page
class LobbyController < ApplicationController
  allow_unauthenticated_access

  def index
    puts "A gambler has entered the casino lobby"
  end

  def logout
    flash[:notice] = "99% of gamblers quit before they win big, I see you're in the minority..."
  end

  # When the horse racing button is pressed, the user is redirected to that games page.
  def horse_racing
    flash[:notice] = "Bet on zoolander, he's my favourite!"
    redirect_to horse_race_betting_path
  end

  # When the roulette button is pressed, the user is redirected to the roulette board page
  def roulette
    flash[:notice] = "Put it all on red!"
    redirect_to roulette_roulette_board_path
  end
end
