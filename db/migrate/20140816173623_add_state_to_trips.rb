class AddStateToTrips < ActiveRecord::Migration
  def change
    add_column :trips, :state, :string
  end
end
