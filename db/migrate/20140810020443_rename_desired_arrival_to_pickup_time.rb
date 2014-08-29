class RenameDesiredArrivalToPickupTime < ActiveRecord::Migration
  def change
		rename_column :rides, :desired_arrival, :pickup_time
  end
end
