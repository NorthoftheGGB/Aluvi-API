class RouteTimesToStrings < ActiveRecord::Migration
  def change
		change_column :routes, :pickup_time, :string
		change_column :routes, :return_time, :string
  end
end
