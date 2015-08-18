class CreateTableAggregate < ActiveRecord::Migration
  def change
    create_table :table_aggregates, id: false do |t|
      t.integer :id
      t.string :state
			t.point :meeting_point, :geographic => true
			t.string :meeting_point_place_name
			t.point :drop_off_point, :geographic => true
			t.string :drop_off_point_place_name
			t.datetime :pickup_time
			t.string :driver_direction
    end
  end
end
