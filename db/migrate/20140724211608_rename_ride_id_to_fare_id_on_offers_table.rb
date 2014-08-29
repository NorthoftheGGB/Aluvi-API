class RenameRideIdToFareIdOnOffersTable < ActiveRecord::Migration
  def change
		rename_column :offers, :ride_id, :fare_id
  end
end
