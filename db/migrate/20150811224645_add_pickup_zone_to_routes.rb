class AddPickupZoneToRoutes < ActiveRecord::Migration
  def change
		add_column :routes, :pickup_zone_center, :st_point, :geographic => true
		add_column :routes, :pickup_zone_center_place_name, :string
  end
end
