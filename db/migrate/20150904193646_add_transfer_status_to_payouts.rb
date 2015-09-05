class AddTransferStatusToPayouts < ActiveRecord::Migration
  def change
    add_column :payouts, :stripe_transfer_status, :string
  end
end
