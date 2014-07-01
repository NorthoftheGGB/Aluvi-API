class AddCommuterFieldsToRideRequests < ActiveRecord::Migration
  def change
    add_column :ride_requests, :desired_arrival, :datetime
  end
end
