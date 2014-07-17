class AddDriverEarningsToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :driver_earnings_cents, :integer
  end
end
