class CreateRides < ActiveRecord::Migration
  def change
    create_table :rides, :options => 'ENGINE=InnoDB' do |t|
      t.references :user
      t.references :car
      t.string :state
      t.datetime :scheduled
      t.datetime :started
      t.datetime :finished
      t.column :meeting_point, :point
      t.string :meeting_point_place_name
      t.column :destination, :point
      t.string :destination_place_name

      t.timestamps
    end
		change_table :rides do |t|
			#t.index :meeting_point, :spatial=>true
			#t.index :destination, :spatial=>true
		end
  end
end
