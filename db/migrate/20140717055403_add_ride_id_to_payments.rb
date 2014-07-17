class AddRideIdToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :ride_id, :integer
  end
end
