# A model that represents a wager by a user on a horse's performance
class Wager < ApplicationRecord
  belongs_to :user
  belongs_to :horse

  validates :amount, presence: true, numericality: true
  validates :kind, presence: true, inclusion: { in: %w[straight place show], message: "%<value>s is not a valid kind type" }

  def payout
    odds = Horse.find(horse_id).odds(kind)
    odds * amount
  end

  # Gets the tooltip when hovered over the bet buttons
  def self.tooltip(kind)
    tooltip = {
      straight: "if the horse comes in 1st place, the bet is a winner",
      place: "if the horse comes in 1st or 2nd place, the bet is a winner",
      show: "if the horse comes in 1st, 2nd or 3rd place, the bet is a winner"
    }

    tooltip[kind.to_sym]
  end

  def self.type_text(kind)
    type = {
      straight: "Straight",
      place: "Place",
      show: "Show"
    }

    type[kind.to_sym]
  end

  # Based on the horse's place did the wager hit?
  def hits?(place)
    case kind.to_sym
    when :straight
      place <= 1 # Bet hits if horse get 1st place
    when :place
      place <= 2 # Bet hits if horse get 1st or 2d place
    when :show
      place <= 3 # Bet hits if horse gets 1st, 2nd or 3rd place
    else
      false      # Otherwise the bet didn't hit
    end
  end

  # Pay the winner
  def fufill # rubocop:disable Metrics/AbcSize
    puts "Paying '#{User.find(user_id).username}' $#{format('%.2f', payout)} for a #{kind.to_s.capitalize} bet of on '#{Horse.find(horse_id).name}'"
    user = User.find(user_id)
    user.balance += payout.round(2)
    user.save

    ActionCable.server.broadcast("horse_wager_channel", { message: payout_message })
  end

  def payout_message
    {
      horse_name: Horse.find(horse_id).name,
      payout: payout.round(2),
      bet_type: Wager.type_text(kind)
    }
  end
end
