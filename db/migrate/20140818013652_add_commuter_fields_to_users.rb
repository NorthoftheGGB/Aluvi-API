class AddCommuterFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :commuter_pickup_time, :string
    add_column :users, :commuter_origin, :point
    add_column :users, :commuter_destination, :point
    add_column :users, :commuter_return_time, :string
  end
end
