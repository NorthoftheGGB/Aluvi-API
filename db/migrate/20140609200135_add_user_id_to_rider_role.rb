class AddUserIdToRiderRole < ActiveRecord::Migration
  def change
    add_column :rider_roles, :user_id, :integer
  end
end
