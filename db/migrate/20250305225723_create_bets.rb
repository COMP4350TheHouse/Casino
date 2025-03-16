# Create empty bets table
class CreateBets < ActiveRecord::Migration[8.0]
  def change
    create_table :bets do |t|
      t.float :amount
      t.float :bet_id
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
