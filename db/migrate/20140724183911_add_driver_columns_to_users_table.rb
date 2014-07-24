class AddDriverColumnsToUsersTable < ActiveRecord::Migration
	def up
		add_attachment :users, :drivers_license
		add_attachment :users, :vehicle_registration
		add_attachment :users, :proof_of_insurance
		add_attachment :users, :national_database_check
		add_column :users, :drivers_license, :string
	end

	def down
		remove_attachment :users, :drivers_license
		remove_attachment :users, :vehicle_registration
		remove_attachment :users, :proof_of_insurance
		remove_attachment :users, :national_database_check
		drop_column :users, :drivers_license, :string
	end
end
