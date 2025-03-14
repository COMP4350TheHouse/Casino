require "test_helper"

class LobbyControllerTest < ActionDispatch::IntegrationTest
  # Test for the coming soon buttons/tables (roulette & slots)
  test "should show coming soon/under construction tables" do
    get lobby_path
    assert_select "button.coming-soon", count: 1
  end

  # Verify that the horse racing table exists
  test "should check that the horse racing table exists" do
    get lobby_path
    assert_select "div.lobby-game#horse-racing"
  end

  # Verify that the roulette table exists
  test "should check that the roulette table exists" do
    get lobby_path
    assert_select "div.lobby-game#roulette"
  end

  # Verify that the slots exists
  test "should check that the slots exists" do
    get lobby_path
    assert_select "div.lobby-game#slots"
  end

  # Test for the arriving at the casino lobby page
  test "should get lobby index" do
    get lobby_path
    assert_response :success
  end

  # Test for pressing the log out button to return to new session page
  test "should log out and delete session" do
    delete session_path
    assert_redirected_to new_session_path
  end

  # Test for pressing the horse racing button to redirect to the horse racing game
  test "should redirect to horse racing" do
    get lobby_path
    assert_response :success
    post horse_racing_lobby_path
    assert_redirected_to horse_race_betting_path
  end

  test "regenerate all horse" do
  end
end
