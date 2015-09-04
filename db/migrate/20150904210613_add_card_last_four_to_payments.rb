class AddCardLastFourToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :card_last4, :string
  end
end
