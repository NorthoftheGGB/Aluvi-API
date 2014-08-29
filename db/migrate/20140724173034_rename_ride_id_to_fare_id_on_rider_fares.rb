class RenameRideIdToFareIdOnRiderFares < ActiveRecord::Migration
  def change
		rename_column :rider_fares, :ride_id, :fare_id
  end
end
