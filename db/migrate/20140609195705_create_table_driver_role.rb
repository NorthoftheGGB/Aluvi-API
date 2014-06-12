class CreateTableDriverRole < ActiveRecord::Migration
  def change
			create_table :driver_roles do |t|
				t.string :state
			end
  end

end
