class AddPayoutRequestedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :payout_requested, :boolean, :default => false
  end
end
