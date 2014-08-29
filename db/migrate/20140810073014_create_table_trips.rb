class CreateTableTrips < ActiveRecord::Migration
  def change
    create_table :table_trips do |t|
			t.timestamps
    end
  end
end
