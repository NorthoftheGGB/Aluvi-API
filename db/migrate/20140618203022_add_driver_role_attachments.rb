class AddDriverRoleAttachments < ActiveRecord::Migration
  def up
		add_attachment :driver_roles, :drivers_license
		add_attachment :driver_roles, :vehicle_registration
		add_attachment :driver_roles, :proof_of_insurance
		add_attachment :driver_roles, :car_photo
		add_attachment :driver_roles, :national_database_check
  end

  def down
		remove_attachment :driver_roles, :drivers_license
		remove_attachment :driver_roles, :vehicle_registration
		remove_attachment :driver_roles, :proof_of_insurance
		remove_attachment :driver_roles, :car_photo
		remove_attachment :driver_roles, :national_database_check
  end
end
