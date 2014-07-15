class CreateDriverLocationHistories < ActiveRecord::Migration
  def change
    create_table :driver_location_histories do |t|
      t.integer :driver_id
      t.integer :fare_id
      t.datetime :datetime
      t.point :location, :geographic => true

      t.timestamps
    end
  end
end
