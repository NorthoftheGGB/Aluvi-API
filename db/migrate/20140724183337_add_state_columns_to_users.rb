class AddStateColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :driver_state, :string
    add_column :users, :rider_state, :string
  end
end
