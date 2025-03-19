# Add boolean flag to know when to pay the users their daily allowance
class AddAllowancePaidToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :allowance_paid, :boolean, null: false, default: false
  end
end
