class AddReceiptsToTrips < ActiveRecord::Migration
  def change
    add_column :receipts, :trip_id, :integer
    add_foreign_key :receipts, :trips
    add_column :receipts, :user_id, :integer
    add_foreign_key :receipts, :users
  end
end
