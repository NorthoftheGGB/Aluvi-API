class ChangeUserIdColumnToDriverId < ActiveRecord::Migration
  def change
		rename_column :rides, :user_id, :driver_id
  end
end
