class RenameFixedCostToFixedPrice < ActiveRecord::Migration
  def change
		rename_column :rides, :fixed_cost, :fixed_price
  end
end
