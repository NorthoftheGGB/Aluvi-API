class AddCardLastFourToPayouts < ActiveRecord::Migration
  def change
    add_column :payouts, :card_last4, :string
  end
end
