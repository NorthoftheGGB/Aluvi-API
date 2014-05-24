class AddStateToOfferedRides < ActiveRecord::Migration
  def change
    add_column :offered_rides, :state, :string
  end
end
