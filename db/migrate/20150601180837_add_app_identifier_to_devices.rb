class AddAppIdentifierToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :app_identifier, :string
  end
end
