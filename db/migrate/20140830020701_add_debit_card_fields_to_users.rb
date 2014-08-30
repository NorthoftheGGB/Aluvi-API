class AddDebitCardFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :recipient_card_brand, :string
    add_column :users, :recipient_card_exp_month, :string
    add_column :users, :recipient_card_month, :string
    add_column :users, :recipient_card_last4, :string
  end
end
