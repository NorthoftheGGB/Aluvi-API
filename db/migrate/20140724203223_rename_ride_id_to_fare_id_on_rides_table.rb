class RenameRideIdToFareIdOnRidesTable < ActiveRecord::Migration
  def change
		rename_column :rides, :ride_id, :fare_id
  end
end
