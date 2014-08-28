class RenameFixedCostToFixedEarnings < ActiveRecord::Migration
  def change
		rename_column :fares, :fixed_cost, :fixed_earnings
  end
end
