class ChangeRideRequestsRenameTypeColumn < ActiveRecord::Migration
  def change
		rename_column :ride_requests, :type, :request_type
  end
end
