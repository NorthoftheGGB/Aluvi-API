class CarsRenameUserIdToDriverId < ActiveRecord::Migration
  def change
		rename_column :cars, :user_id, :driver_id
  end
end
