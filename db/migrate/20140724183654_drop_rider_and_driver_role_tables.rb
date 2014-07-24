class DropRiderAndDriverRoleTables < ActiveRecord::Migration
  def change
		drop_table :driver_roles
		drop_table :rider_roles
  end
end
