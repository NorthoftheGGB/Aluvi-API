class AddTripIdAndDirectionToRide < ActiveRecord::Migration
  def change
    add_column :rides, :trip_id, :integer
    add_column :rides, :direction, :string
  end
end
