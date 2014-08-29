class RenameRideRidesTableToRiderFares < ActiveRecord::Migration
  def change
		rename_table :rider_rides, :rider_fares
  end
end
