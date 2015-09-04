class AddSuccessToPayouts < ActiveRecord::Migration
  def change
    add_column :payouts, :success, :boolean, :default => false
  end
end
