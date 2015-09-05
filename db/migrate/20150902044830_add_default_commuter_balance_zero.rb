class AddDefaultCommuterBalanceZero < ActiveRecord::Migration
  def change
    change_column :users, :commuter_balance_cents, :integer, default: 0
  end
end
