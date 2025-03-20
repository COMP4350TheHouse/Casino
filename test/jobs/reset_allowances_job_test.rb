require "test_helper"

class ResetAllowancesJobTest < ActiveJob::TestCase
  test "Job resets allowance_paid flag for a user" do
    user = User.find_by(username: "one1")
    assert user.allowance_paid # Make sure the allowance paid is true

    ResetAllowancesJob.perform_now
    assert_not user.reload.allowance_paid # Test that it got set to false
  end

  test "Job resets allowance_paid flag for all users" do
    ResetAllowancesJob.perform_now
    User.all.each do |user|
      assert_not user.allowance_paid
    end
  end
end
