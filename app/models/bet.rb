# A model that represents a bet by a user on a roulette cell
class Bet < ApplicationRecord
  belongs_to :user
  validates :amount, presence: true, numericality: true
end
