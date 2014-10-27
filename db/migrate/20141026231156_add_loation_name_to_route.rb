class AddLoationNameToRoute < ActiveRecord::Migration
  def change
		add_column :routes, :destination_place_name, :string
		add_column :routes, :origin_place_name, :string
  end
end
