# Model for the Horse class
class Horse < ApplicationRecord
  has_many :wagers, dependent: :destroy

  NAMES        = (1..100).map { |x| "MyHorse#{x}" }
  IMAGES       = ['horse1.png'].freeze
  SPEEDS       = (5..10).freeze
  TIMINGS      = %w[linear ease ease-in ease-out ease-in-out].freeze
  ODDS         = (1..100).freeze

  def self.random # rubocop:disable Metrics/AbcSize
    name          = NAMES.sample      # Random name for horse
    image         = IMAGES.sample     # Random image of the horse
    speed         = rand(SPEEDS) + rand # Random speed, this tells us if horse is gonna win the race
    timing        = TIMINGS.sample # Random timing so horses move in interesting ways
    show_odds     = rand(ODDS) + rand # Random odds for payout if horse gets 1st, 2nd or 3rd
    place_odds    = show_odds * 2 + rand  # Random odds for payout if horse gets 1st or 2nd this has to be bigger than show_odds
    straight_odds = place_odds * 2 + rand # Random odds for payout if horse gets 1st, this has to be bigger than place_odds

    Horse.new(name: name, image: image, speed: speed, timing: timing, show_odds: show_odds, place_odds: place_odds, straight_odds: straight_odds)
  end

  # Remove Horse at random
  def self.remove_random_horses(amount = 1)
    amount.times do |_|
      next unless Horse.count.positive?

      unlucky_horse = Horse.choose_random_horse_based_on_performance
      unlucky_horse.destroy # Remove unlucky horse
    end
  end

  # Choose a random horse from current selection, its most likely going to be the slowest horse, least likely to be the fastest horse
  def self.choose_random_horse_based_on_performance
    odds = (1..Horse.count).map { |i| 2.0 * i / (Horse.count * (Horse.count + 1)) }

    weight_sum = 0
    cumulative_weights = odds.map { |x| weight_sum += x }

    remove             = rand
    remove_index       = cumulative_weights.index { |weight| remove < weight }

    Horse.order(:speed)[remove_index] # Bye Bye
  end

  # Creates a new random horse
  def self.create_new_horse
    Horse.random.save
  end

  def odds(kind)
    # When working with ruby I sometimes use symbols, but we store them as string on the database, this lets me use either or
    kind = kind.to_sym if kind.is_a?(String)

    case kind
    when :straight
      straight_odds
    when :place
      place_odds
    when :show
      show_odds
    end
  end

  def animation
    "moveImage #{speed}s #{timing} forwards, jostleImage ease-in-out 0.1s infinite alternate;"
  end
end
