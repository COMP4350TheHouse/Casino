# Model for the Horse class
class Horse < ApplicationRecord
  has_many :wagers, dependent: :destroy

  NAMES        = ['Joey', 'Seabiscuit', 'Khan', 'Maximus', 'Donkey', 'Man o\'war'].freeze
  IMAGES       = ['horse1.png', 'horse2.png', 'horse3.png', 'horse4.png', 'horse5.png', 'horse6.png'].freeze
  SPEEDS       = (0..8).freeze
  ODDS         = (4..5).freeze

  BASE_SPEED   = 5

  def self.random # rubocop:disable Metrics/AbcSize
    horse_index = Horse.count % IMAGES.length
    name          = NAMES[horse_index]      # Random name for horse
    image         = IMAGES[horse_index]     # Random image of the horse
    speed         = rand(SPEEDS) # Random speed, this tells us if horse is gonna win the race
    straight_odds = rand(ODDS) + 0.01 + rand # Random odds for payout if horse gets 1st, this has to be bigger than place_odds
    place_odds    = straight_odds / 2.0 # Random odds for payout if horse gets 1st or 2nd this has to be bigger than show_odds
    show_odds     = straight_odds / 3.0 # Random odds for payout if horse gets 1st, 2nd or 3rd

    # Round them out to be whole numbers
    straight_odds = straight_odds.round(1)
    place_odds = place_odds.round(1)
    show_odds = show_odds.round(1)

    Horse.new(name: name, image: image, speed: speed, show_odds: show_odds, place_odds: place_odds, straight_odds: straight_odds, position: 0)
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

  def tick
    # Race hasn't finished, continue moving
    move_forward if position < 100
    payout_wagers if position > 100
  end

  def move_forward
    self.position += BASE_SPEED + SPEEDS.to_a.sample
    save
  end

  def payout_wagers
    placing = place
    self.position = 1000 # Once a horse is finished put it so far forward it can't be passed
    save

    wagers = Wager.all.where(horse_id: id) # Wagers on me (me being the horse)
    winning_wagers = wagers.select { |wager| wager.hits?(placing) } # Wagers that hit based on wager kind and actual horse placing
    winning_wagers.each(&:fufill) # Pay the money

    wagers.destroy_all
  end

  def self.clear_all_wagers
    wagers = Wager.all # Wagers on me (me being the horse)
    wagers.destroy_all
  end

  # Find out what place we're in atm
  def place
    Horse.order(position: :desc).find_index { |horse| horse.id == id } + 1
  end

  def self.race_message
    Horse.all.map do |horse|
      { id: horse.id,
        position: horse.position }
    end
  end
end
