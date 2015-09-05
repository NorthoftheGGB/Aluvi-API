class AddFreeRidesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :free_rides, :integer
  end
end
