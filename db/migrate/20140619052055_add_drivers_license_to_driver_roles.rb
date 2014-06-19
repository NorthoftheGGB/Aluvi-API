class AddDriversLicenseToDriverRoles < ActiveRecord::Migration
  def change
    add_column :driver_roles, :drivers_license, :string
  end
end
