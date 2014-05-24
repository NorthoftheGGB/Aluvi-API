class ChangeOfferedRidesRenameRiderIdToRideId < ActiveRecord::Migration
  def change
		rename_column :offered_rides, :rider_id, :ride_id
  end
end
