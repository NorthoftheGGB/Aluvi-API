class AddNotifiedToTrips < ActiveRecord::Migration
  def change
    add_column :trips, :notified, :boolean
  end
end
