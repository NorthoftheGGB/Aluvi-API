class AddCommuterRefillEnabledToUsers < ActiveRecord::Migration
  def change
    add_column :users, :commuter_refill_enabled, :boolean
  end
end
