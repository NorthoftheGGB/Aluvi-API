class DropTableTempFares < ActiveRecord::Migration
  def change
		drop_table :temp_fares
  end
end
