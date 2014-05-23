class CreateOfferedRides < ActiveRecord::Migration
  def change
    create_table :offered_rides do |t|
      t.integer :driver_id
      t.integer :rider_id

      t.timestamps
    end
  end
end
