class AddStartTimeToTrips < ActiveRecord::Migration
  def change
    add_column :trips, :start_time, :datetime
  end
end
