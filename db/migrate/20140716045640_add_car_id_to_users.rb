class AddCarIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :car_id, :integer
		remove_column :cars, :car_id
  end
end
