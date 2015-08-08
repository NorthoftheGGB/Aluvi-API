class RemoveFieldFromTempFares < ActiveRecord::Migration
	def change
		remove_column :temp_fares, :driver_id
		remove_column :temp_fares, :car_id
  end
end
