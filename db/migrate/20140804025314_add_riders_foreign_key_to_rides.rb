class AddRidersForeignKeyToRides < ActiveRecord::Migration
  def up
		add_foreign_key(:rides, :users, column: 'rider_id')
  end

	def down
		remove_foreign_key(:rides, :users, column: 'rider_id')
	end
end
