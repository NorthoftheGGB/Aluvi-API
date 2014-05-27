class RenameUserIdToRiderIdInRiderRides < ActiveRecord::Migration
  def change
		rename_column :rider_rides, :user_id, :rider_id
  end
end
