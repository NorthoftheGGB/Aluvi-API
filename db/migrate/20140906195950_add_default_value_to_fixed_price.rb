class AddDefaultValueToFixedPrice < ActiveRecord::Migration
  def change
		change_column :rides, :fixed_price, :integer, :default => 0
  end
end
