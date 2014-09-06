class AddDefaultToFixedEarnings < ActiveRecord::Migration
  def change
		change_column :fares, :fixed_earnings, :integer, :default => 0
  end
end
