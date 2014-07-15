class CreateRideRequests < ActiveRecord::Migration
  def change
    create_table :ride_requests do |t|
      t.references :user
      t.references :ride
      t.string :state
      t.string :type
      t.datetime :requested_datetime
      t.point :origin, :geographic => true
      t.string :origin_place_name
      t.point :destination, :geographic => true
      t.string :destination_place_name

      t.timestamps
    end
		change_table :ride_requests do |t|
			#t.index :origin, :spatial=>true
			#t.index :destination, :spatial=>true
		end
  end
end
