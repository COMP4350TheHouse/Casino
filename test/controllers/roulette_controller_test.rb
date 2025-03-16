require 'test_helper'

class RouletteControllerTest < ActionDispatch::IntegrationTest
  # To access roulette, we must first be logged in
  def login
    post session_path, params: { session: { username: 'three3', password: 'password' } }
    assert_response :redirect
  end

  # Go from the lobby page to the roulette game page
  test 'should get roulette game path' do
    login
    get roulette_roulette_board_path
    assert_response :success
  end

  # Roulette Betting + return json
  def place_bet(params)
    post submit_roulette_bet_path, params: params
    assert_response :success
    JSON.parse(response.body)
  end

  # Payout bets + return json
  def payout_bets(params)
    post payout_bets_path, params: params
    assert_response :success
    JSON.parse(response.body)
  end

  # Test that the balance shows up on screen
  test 'balance should be available' do
    login
    get roulette_roulette_board_path
    assert_select 'div.roulette-balance#balance'
  end

  # Test that the roulette spin countdown bar shows up on screen
  test 'roulette countdown should be available' do
    login
    get roulette_roulette_board_path
    assert_select 'div.progress-fill#progressFill'
  end

  # Test that the roulette wheel shows up on screen
  test 'roulette wheel should be available' do
    login
    get roulette_roulette_board_path
    assert_select 'div.spinner'
  end

  # Test that the roulette board shows up on screen
  test 'roulette board should be available' do
    login
    get roulette_roulette_board_path
    assert_select 'div.roulette'
  end

  # Test that the chip selection shows up on screen
  test 'chip selection should be available' do
    login
    get roulette_roulette_board_path
    assert_select 'div.chip-selection#chipContainer'
  end

  # Should be able to place bet on each of the available cells
  test 'should place all bet types' do
    login
    (0..48).each do |bet_id|
      place_bet({ amount: 1, bet_id: bet_id })
    end
  end

  # Make invalid bet (bet more than current balance) and verify that it doesnt exist
  test 'bet shouldnt place' do
    login
    data = place_bet({ amount: 10000, bet_id: 0 })
    assert_equal false, data['valid_bet']
  end

  # Make valid bet on winning number and ensure it pays out
  test 'valid bet and win' do
    login

    # Place bet on winning number
    place_bet({ amount: 1, bet_id: 1 })

    # Get balance
    user = User.first
    curr_balance = user.balance

    # Payout our bet
    payout_bets({ winning_num: 1 })
    data = JSON.parse(response.body)
    new_balance = data['balance'].to_f

    # Verify user balance has increased
    assert new_balance > curr_balance
  end

  # Make valid bet on non-winning number and ensure it DOESNT pay out
  test 'valid bet and lose' do
    login

    # Place bet on winning number 2
    place_bet({ amount: 1, bet_id: 2 })

    # Get balance
    user = User.first
    curr_balance = user.balance
    puts "balance is #{curr_balance}"

    # Payout our bet
    payout_bets({ winning_num: 1 })
    data = JSON.parse(response.body)
    new_balance = data['balance'].to_f
    puts "balance is now #{new_balance}"

    # Verify user balance has increased
    assert new_balance <= curr_balance
  end
end
