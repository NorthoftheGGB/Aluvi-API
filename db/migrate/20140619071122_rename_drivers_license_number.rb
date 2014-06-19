class RenameDriversLicenseNumber < ActiveRecord::Migration
  def change
		rename_column :driver_roles, :drivers_license, :drivers_license_number
  end
end
