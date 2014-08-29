class RenameTrips < ActiveRecord::Migration
  def change
		rename_table :table_trips, :trips
  end
end
