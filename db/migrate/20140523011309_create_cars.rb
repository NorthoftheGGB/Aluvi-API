class CreateCars < ActiveRecord::Migration
  def change
    create_table :cars do |t|
      t.references :user
      t.string :make
      t.string :model
      t.string :license_plate
      t.string :state
      t.point :location, :geographic => true

      t.timestamps
    end
		change_table :cars do |t|
			#t.index :location, :spatial => true
		end
  end
end
