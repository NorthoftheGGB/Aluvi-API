class AddPaymentModeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :payment_mode, :integer, :default => 0, :null => false
  end
end
