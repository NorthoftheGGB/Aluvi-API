class CreateRiderRides < ActiveRecord::Migration
  def change
    create_table :rider_rides, :options => 'ENGINE=InnoDB' do |t|
      t.references :user
      t.references :ride

      t.timestamps
    end
  end
end
