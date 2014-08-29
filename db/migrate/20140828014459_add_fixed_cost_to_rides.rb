class AddFixedCostToRides < ActiveRecord::Migration
  def change
    add_column :rides, :fixed_cost, :integer
  end
end
