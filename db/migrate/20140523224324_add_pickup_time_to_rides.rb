class AddPickupTimeToRides < ActiveRecord::Migration
  def change
    add_column :rides, :pickup_time, :datetime
  end
end
