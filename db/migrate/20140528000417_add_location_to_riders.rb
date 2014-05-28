class AddLocationToRiders < ActiveRecord::Migration
  def change
    add_column :users, :rider_location, :point
  end
end
