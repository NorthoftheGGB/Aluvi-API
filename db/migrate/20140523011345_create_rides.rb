class CreateRides < ActiveRecord::Migration
  def change
    create_table :rides do |t|
      t.references :user
      t.references :car
      t.string :state
      t.datetime :scheduled
      t.datetime :started
      t.datetime :finished
      t.point :meeting_point, :geographic => true
      t.string :meeting_point_place_name
      t.point :destination, :geographic => true
      t.string :destination_place_name

      t.timestamps
    end
		change_table :rides do |t|
			#t.index :meeting_point, :spatial=>true
			#t.index :destination, :spatial=>true
		end
  end
end
