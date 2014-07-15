class CreateRiderRides < ActiveRecord::Migration
  def change
    create_table :rider_rides do |t|
      t.references :user
      t.references :ride

      t.timestamps
    end
  end
end
