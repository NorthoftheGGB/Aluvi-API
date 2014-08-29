class RenameUserIdToRiderIdOnRidesTable < ActiveRecord::Migration
  def change
		rename_column :rides, :user_id, :rider_id
  end
end
