class AddDrivingToRides < ActiveRecord::Migration
  def change
    add_column :rides, :driving, :boolean
  end
end
