class AddCurrentFairIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :current_fare_id, :integer
  end
end
