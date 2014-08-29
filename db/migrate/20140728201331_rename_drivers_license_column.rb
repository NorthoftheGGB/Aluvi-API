class RenameDriversLicenseColumn < ActiveRecord::Migration
  def change
		rename_column :users, :drivers_license, :drivers_license_number
  end
end
