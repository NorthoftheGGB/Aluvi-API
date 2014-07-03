class ChangeDestinationToDropOff < ActiveRecord::Migration
  def change
		 rename_column :rides, :destination, :drop_off_point
		 rename_column :rides, :destination_place_name, :drop_off_point_place_name
  end
end
