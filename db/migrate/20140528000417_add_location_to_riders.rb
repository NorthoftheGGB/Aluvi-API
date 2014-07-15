class AddLocationToRiders < ActiveRecord::Migration
  def change
    add_column :users, :rider_location, :point, :srid => 4326 
  end
end
