# Add Position feild to Horses
class AddPositionToHorses < ActiveRecord::Migration[8.0]
  def change
    add_column :horses, :position, :float
  end
end
