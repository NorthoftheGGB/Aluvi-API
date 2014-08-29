class AddTimezoneToPickupTime < ActiveRecord::Migration
  def up
		change_column :rides, :pickup_time, 'timestamp with time zone'
  end

  def down
		change_column :rides, :pickup_time, 'timestamp without time zone'
  end
end
