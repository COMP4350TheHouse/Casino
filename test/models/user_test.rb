require "test_helper"

class UserTest < ActiveSupport::TestCase
  ## Test valid insertions

  test "should insert user" do
    user = User.new(email_address: "user@email.com", username: "user", password: "password")
    assert user.save
  end

  test "should insert user with password confirmation" do
    user = User.new(email_address: "user2@email.com", username: "user2", password: "password", password_confirmation: "password")
    assert user.save
  end

  test "should insert user with symbols" do
    user = User.new(email_address: "symbols@email.com", username: "user_with-symbol", password: "password")
    assert user.save
  end

  ## Test missing parameters

  test "must provide email address" do
    user = User.new(username: "user3", password: "password")
    assert_not user.save
  end

  test "must provide username" do
    user = User.new(email_address: "user3@email.com", password: "password")
    assert_not user.save
  end

  test "must provide password" do
    user = User.new(email_address: "user3@email.com", username: "user3")
    assert_not user.save
  end

  ## Test duplicate values

  test "no duplicate email address" do
    user = User.new(email_address: "one@example.com", username: "user3", password: "password")
    assert_not user.save
  end

  test "no duplicate email address ignore case" do
    user = User.new(email_address: "ONE@EXAMPLE.COM", username: "user3", password: "password")
    assert_not user.save
  end

  test "no duplicate username" do
    user = User.new(email_address: "user3@email.com", username: "one1", password: "password")
    assert_not user.save
  end

  test "no duplicate username ignore case" do
    user = User.new(email_address: "user3@email.com", username: "ONE1", password: "password")
    assert_not user.save
  end

  ## Validate parameters

  test "email address must be valid" do
    user = User.new(email_address: "invalid", username: "user3", password: "password")
    assert_not user.save
  end

  test "username must be valid" do
    user = User.new(email_address: "user3@email.com", username: "invalid user", password: "password")
    assert_not user.save
  end

  test "username min length" do
    user = User.new(email_address: "user3@email.com", username: "aaa", password: "password")
    assert_not user.save
  end

  test "username max length" do
    user = User.new(email_address: "user3@email.com", username: "username_too_long", password: "password")
    assert_not user.save
  end

  test "password must match confirmation" do
    user = User.new(email_address: "user3@email.com", username: "user3", password: "password", password_confirmation: "password2")
    assert_not user.save
  end

  ## Test balance values

  test "balance can change" do
    user = User.find_by username: "one1"
    user.balance = 0
    assert user.save
    assert_equal user.balance, 0

    user.balance += 1.25
    assert user.save
    assert_equal user.balance, 1.25
  end

  test "balance rounds to two digits" do
    user = User.find_by username: "one1"
    user.balance = 1.251
    assert user.save

    assert_equal user.balance, 1.25
  end

  test "balance must not be negative" do
    user = User.find_by username: "one1"
    user.balance = -1
    assert_not user.save
  end

  test "pay allowance increases balance by daily allowance" do
    user = User.find_by username: "four4"
    balance = user.balance

    user.pay_allowance

    assert user.balance == balance + User::DAILY_ALLOWANCE
  end

  test "pay allowance resets allowance paid flag" do
    user = User.find_by username: "four4"
    assert_not user.allowance_paid

    user.pay_allowance

    assert user.allowance_paid
  end
end
