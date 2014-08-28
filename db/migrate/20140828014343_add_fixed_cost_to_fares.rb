class AddFixedCostToFares < ActiveRecord::Migration
  def change
    add_column :fares, :fixed_cost, :integer
  end
end
