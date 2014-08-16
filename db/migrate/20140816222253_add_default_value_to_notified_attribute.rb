class AddDefaultValueToNotifiedAttribute < ActiveRecord::Migration
	def up
		  change_column :trips, :notified, :boolean, :default => false
	end

	def down
		  change_column :trips, :notified, :boolean, :default => nil
	end
end
