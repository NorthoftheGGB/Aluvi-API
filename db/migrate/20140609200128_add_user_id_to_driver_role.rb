class AddUserIdToDriverRole < ActiveRecord::Migration
  def change
    add_column :driver_roles, :user_id, :integer
  end
end
