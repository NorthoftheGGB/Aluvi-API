class AddBankAccountNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :bank_account_name, :string
  end
end
