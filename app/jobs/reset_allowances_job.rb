# A scheduled job to reset the daily allowance_paid flag in the database for all users
class ResetAllowancesJob < ApplicationJob
  queue_as :default

  def perform
    puts "Resetting Allowances"
    User.where(allowance_paid: true).update_all(allowance_paid: false)
  end
end
