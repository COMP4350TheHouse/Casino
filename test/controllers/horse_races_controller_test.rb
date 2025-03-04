require "test_helper"

class HorseRacesControllerTest < ActionDispatch::IntegrationTest # rubocop:disable Metrics/ClassLength
  def login
    post session_path, params: { session: { username: "one1", password: "password" } }
    assert_response :redirect
  end

  test "should get race betting path" do
    login
    get horse_race_betting_path
    assert_response :success
  end

  # Horse Race Betting
  def place_bet(params)
    post submit_bet_path, params: params
    assert_response :redirect
  end

  def does_wager_pay(kind, place)
    user = User.first
    user_id = user.id
    balance = user.balance
    winner = Horse.order(:speed)[place]
    place_bet({ horse: winner.id, kind: kind, amount: 1.00 })
    post resolve_race_path

    assert balance * winner.odds(kind) == User.find(user_id).balance
  end

  def does_wager_not_pay(kind, place)
    user = User.first
    winner = Horse.order(:speed)[place]
    bet_amount = 1.00

    place_bet({ horse: winner.id, kind: kind, amount: bet_amount })
    post resolve_race_path

    assert user.balance
  end

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

    loser = Horse.order(speed: :desc).first

    place_bet({ horse: loser.id, kind: kind, amount: amount })
    post resolve_race_path

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
