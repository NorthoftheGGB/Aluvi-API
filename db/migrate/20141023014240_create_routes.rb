class CreateRoutes < ActiveRecord::Migration
  def change
    create_table :routes do |t|
      t.integer :rider_id
      t.point :origin, :geographic => true
			t.column :pickup_time, 'timestamp with time zone'
      t.point :destination, :geographic => true
			t.column :return_time, 'timestamp with time zone'
      t.boolean :driving
      t.timestamps
    end
  end
end
