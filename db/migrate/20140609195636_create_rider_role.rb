class CreateRiderRole < ActiveRecord::Migration
  def change
			create_table :rider_roles do |t|
				t.string :state
			end
  end
end
