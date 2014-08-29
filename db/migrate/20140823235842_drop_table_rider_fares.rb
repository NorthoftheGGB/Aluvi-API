class DropTableRiderFares < ActiveRecord::Migration
  def change
		drop_table :rider_fares
  end
end
