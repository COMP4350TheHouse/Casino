require "test_helper"
require "pp"

class HorseRacesControllerTest < ActionDispatch::IntegrationTest # rubocop:disable Metrics/ClassLength
  def login
    post session_path, params: { session: { username: "one1", password: "password" } }
    assert_response :redirect
  end

  def does_wager_pay(kind, place)
    wager = Wager.new(kind: kind)
    wager.hits?(place)
  end

  def does_wager_not_pay(kind, place)
    !does_wager_pay(kind, place)
  end

  test "should navigate to horse race" do
    login
    get horse_race_index_path
    assert_response :success
  end

  # Horse Race Betting
  def place_bet(params)
    post submit_bet_path, params: params
    assert_response :success
  end

  def does_wager_hit?(wager)
    horse = Horse.find(wager.horse_id)
    wager.hits?(horse.place)
  end

  def do_all_wagers_hit?(user_id)
    Wager.where(user_id: user_id).all? { |wager| does_wager_hit?(wager) }
  end

  def make_horse_finish(horse, place = :none)
    position = {
      straight: 3,
      place: 2,
      show: 1,
      none: 0
    }[place]

    winner = Horse.find(horse.id)
    winner.position = 100 + position
    winner.save
  end

  test "should place winning straight bet" do
    login
    kind = :straight
    user = User.find_by(username: "one1")

    winner, = Horse.limit(3)
    place_bet({ horse: winner.id, kind: kind, amount: 0.00 })

    make_horse_finish(winner, kind)

    assert do_all_wagers_hit? user.id
  end

  test "should place winning place bet" do
    login
    kind = :place
    user = User.find_by(username: "one1")

    _, winner, = Horse.limit(3)
    place_bet({ horse: winner.id, kind: kind, amount: 0.00 })

    make_horse_finish(winner, kind)

    assert do_all_wagers_hit? user.id
  end

  test "should place winning show bet" do
    login
    kind = :show
    user = User.find_by(username: "one1")

    _, _, winner, = Horse.limit(3)
    place_bet({ horse: winner.id, kind: kind, amount: 0.00 })

    make_horse_finish(winner, kind)

    assert do_all_wagers_hit? user.id
  end

  test "should place winning show, place & straight bet" do
    login
    user = User.find_by(username: "one1")

    straight, place, show = Horse.limit(3)
    place_bet({ horse: straight.id, kind: :straight, amount: 0.00 })
    place_bet({ horse: place.id, kind: :place, amount: 0.00 })
    place_bet({ horse: show.id, kind: :show, amount: 0.00 })

    make_horse_finish(straight, :straight)
    make_horse_finish(place, :straight)
    make_horse_finish(show, :show)

    assert do_all_wagers_hit? user.id
  end

  # def place_winning_bet(kind)
  #   login
  #   # User
  #   amount = 1.00
  #   user = User.find_by(username: "one1")
  #   user.balance = amount
  #   user.save

  #   # Horse
  #   winner = Horse.first # Get a horse, doesnt matter who

  #   # Place wager
  #   place_bet({ horse: winner.id, kind: kind, amount: 1.0 })

  #   # Make winner win
  #   make_horse_finish(winner.id, kind)
  #   winner.payout_wagers

  #   # Make sure bet payed
  #   user.reload
  #   assert user.balance == winner.odds(kind) * amount
  # end

  # def does_wager_pay(kind, place)
  # user = User.first
  # user_id = user.id
  # balance = user.balance
  # winner = Horse.order(:speed)[place]
  # place_bet({ horse: winner.id, kind: kind, amount: 1.00 })
  # post resolve_race_path
  #
  # assert balance * winner.odds(kind) == User.find(user_id).balance
  # end
  #
  # def does_wager_not_pay(kind, place)
  # user = User.first
  # winner = Horse.order(:speed)[place]
  # bet_amount = 1.00
  #
  # place_bet({ horse: winner.id, kind: kind, amount: bet_amount })
  # post resolve_race_path
  #
  # assert user.balance
  # end

  test "should place show bet" do
    login
    place_bet({ horse: Horse.first.id, kind: :show, amount: 0.0 })
  end

  test "should place place bet" do
    login
    place_bet({ horse: Horse.first.id, kind: :place, amount: 0.0 })
  end

  test "should place straight bet" do
    login
    place_bet({ horse: Horse.first.id, kind: :straight, amount: 0.0 })
  end

  test "should place multiple bets on same horse" do
    login
    place_bet({ horse: Horse.first.id, kind: :show, amount: 0.0 })
    place_bet({ horse: Horse.first.id, kind: :place, amount: 0.0 })
    place_bet({ horse: Horse.first.id, kind: :straight, amount: 0.0 })

    assert Wager.count == 3
  end

  test "should place multiple bets on different horses" do
    login
    place_bet({ horse: Horse.first.id, kind: :show, amount: 0.0 })
    place_bet({ horse: Horse.second.id, kind: :place, amount: 0.0 })

    assert Wager.count == 2
  end

  test "should pay user accordingly for sucessful first placed horse show wager" do
    login
    amount = 1.00
    kind = :straight
    me = User.find_by(username: "one1")
    me.balance = amount
    me.save
    Horse.update_all(position: 0) # All horses to start
    winner = Horse.first
    place_bet({ horse: winner.id, kind: kind, amount: 1.00 })

    pp me.reload

    winner.position = 101 # Finishes the race
    winner.save
    winner.payout_wagers
    me.reload

    pp winner.odds(kind) * amount
    pp me.balance

    assert me.balance == winner.odds(kind) * amount
  end

  test "should pay user accordingly for sucessful second placed horse show wager" do
    login
    does_wager_pay :show, 1
  end

  test "should pay user accordingly for sucessful third placed horse show wager" do
    login
    does_wager_pay :show, 2
  end

  test "should not pay user accordingly for horse placed out of the top 3 show wager" do
    login
    does_wager_not_pay :show, 3
    does_wager_not_pay :show, 4
    does_wager_not_pay :show, 5
  end

  test "should not pay user accordingly for horse placed out of the top 2 place wager" do
    login
    does_wager_not_pay :place, 2
    does_wager_not_pay :place, 3
    does_wager_not_pay :place, 4
    does_wager_not_pay :place, 5
  end

  test "should not pay user accordingly for winning horse placed straight wager" do
    login
    does_wager_not_pay :straight, 1
    does_wager_not_pay :straight, 2
    does_wager_not_pay :straight, 3
    does_wager_not_pay :straight, 4
    does_wager_not_pay :straight, 5
  end

  test "should lose user money for a bad bet" do
    login
    user = User.first
    kind = :straight
    amount = 1.0

    User.update(balance: amount)

    Horse.update_all(position: 101) # Make all horses win
    loser = Horse.first
    loser.position = 0 # This horse loses
    loser.save

    place_bet({ horse: loser.id, kind: kind, amount: amount })

    user.reload

    assert user.balance
  end

  test "Creating extra horses" do
    horse_count = Horse.count
    Horse.create_new_horse
    assert Horse.count == horse_count + 1
  end

  test "Removing too many horses" do
    Horse.remove_random_horses(Horse.count + 100)
    assert Horse.count.zero?
  end

  test "Removing all horses" do
    Horse.remove_random_horses(Horse.count)
    assert Horse.count.zero?
  end

  test "Check all horses are eventually removed" do
    starting_horses = Horse.all.uniq # Uniq is needed to clone the elements (Otherwise it's a pointer)

    (1..200).each do |_| # Odds of this failing are 5/6^200... essentially 0
      Horse.remove_random_horses(1)
      Horse.create_new_horse
    end

    assert (starting_horses | Horse.all).count == 12 # The starting horses and remaining horses are entirely unique
  end

  test "Remove Horse, Add Horse" do
    horse_count = Horse.count
    Horse.remove_random_horses(1)
    assert Horse.count == horse_count - 1
    Horse.create_new_horse
    assert Horse.count == horse_count
  end

  test "Regenerate all horses" do
    Horse.remove_random_horses(Horse.count)
    assert Horse.count.zero?
    Horse.create_new_horse
    Horse.create_new_horse
    Horse.create_new_horse
    Horse.create_new_horse
    Horse.create_new_horse
    Horse.create_new_horse
    assert Horse.count == 6
  end

  test "Generated Horses are unique to one-another" do
    Horse.remove_random_horses(Horse.count)
    assert Horse.count.zero?
    Horse.create_new_horse
    Horse.create_new_horse
    Horse.create_new_horse
    Horse.create_new_horse
    Horse.create_new_horse
    Horse.create_new_horse
    assert Horse.count == 6
    # Checks the horses are unique
    unique_horses = Horse.all.uniq
    assert unique_horses.count == Horse.count
  end

  test "Generated Horses are unique to pre-existing horses" do
    horse_count = Horse.count
    Horse.create_new_horse
    Horse.create_new_horse
    Horse.create_new_horse
    Horse.create_new_horse
    Horse.create_new_horse
    Horse.create_new_horse
    assert Horse.count == horse_count + 6
    # Checks the horses are unique
    unique_horses = Horse.all.uniq
    assert unique_horses.count == Horse.count
  end

  test "Betting on one generated horses" do
    Horse.remove_random_horses(Horse.count)
    assert Horse.count.zero?
    Horse.create_new_horse
    Horse.create_new_horse
    Horse.create_new_horse
    Horse.create_new_horse
    Horse.create_new_horse
    Horse.create_new_horse
    assert Horse.count == 6

    # Wagers are placed
    login
    place_bet({ horse: Horse.first.id, kind: :show, amount: 0.0 })

    assert Wager.count == 1
  end

  test "Betting on multiple generated horses" do
    Horse.remove_random_horses(Horse.count)
    assert Horse.count.zero?
    Horse.create_new_horse
    Horse.create_new_horse
    Horse.create_new_horse
    Horse.create_new_horse
    Horse.create_new_horse
    Horse.create_new_horse
    assert Horse.count == 6

    # Wagers are placed
    login
    place_bet({ horse: Horse.first.id, kind: :show, amount: 0.0 })
    place_bet({ horse: Horse.second.id, kind: :place, amount: 0.0 })
    place_bet({ horse: Horse.third.id, kind: :straight, amount: 0.0 })

    assert Wager.count == 3
  end

  test "Betting on one generated horse multiple times" do
    Horse.remove_random_horses(Horse.count)
    assert Horse.count.zero?
    Horse.create_new_horse
    Horse.create_new_horse
    Horse.create_new_horse
    Horse.create_new_horse
    Horse.create_new_horse
    Horse.create_new_horse
    assert Horse.count == 6

    # Wagers are placed
    login
    place_bet({ horse: Horse.first.id, kind: :show, amount: 0.0 })
    place_bet({ horse: Horse.first.id, kind: :place, amount: 0.0 })
    place_bet({ horse: Horse.first.id, kind: :straight, amount: 0.0 })

    assert Wager.count == 3
  end

  test "No payout when betting & losing on generated horses" do
    Horse.remove_random_horses(Horse.count)
    assert Horse.count.zero?
    Horse.create_new_horse
    Horse.create_new_horse
    Horse.create_new_horse
    Horse.create_new_horse
    Horse.create_new_horse
    Horse.create_new_horse
    assert Horse.count == 6

    login

    # Do all the bets on the horses
    does_wager_not_pay :show, 3
    does_wager_not_pay :show, 4
    does_wager_not_pay :show, 5

    does_wager_not_pay :place, 2
    does_wager_not_pay :place, 3
    does_wager_not_pay :place, 4
    does_wager_not_pay :place, 5

    does_wager_not_pay :straight, 1
    does_wager_not_pay :straight, 2
    does_wager_not_pay :straight, 3
    does_wager_not_pay :straight, 4
    does_wager_not_pay :straight, 5
  end
end
