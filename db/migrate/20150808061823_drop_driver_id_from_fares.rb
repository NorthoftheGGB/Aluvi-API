class DropDriverIdFromFares < ActiveRecord::Migration
  def change
		remove_column :fares, :driver_id
		remove_column :fares, :car_id
  end
end
