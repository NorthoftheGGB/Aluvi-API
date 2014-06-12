class CreateRideRequests < ActiveRecord::Migration
  def change
    create_table :ride_requests, :options => 'ENGINE=InnoDB' do |t|
      t.references :user
      t.references :ride
      t.string :state
      t.string :type
      t.datetime :requested_datetime
      t.column :origin, :point
      t.string :origin_place_name
      t.column :destination, :point
      t.string :destination_place_name

      t.timestamps
    end
		change_table :ride_requests do |t|
			#t.index :origin, :spatial=>true
			#t.index :destination, :spatial=>true
		end
  end
end
