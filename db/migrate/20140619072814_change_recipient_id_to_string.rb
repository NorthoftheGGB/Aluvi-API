class ChangeRecipientIdToString < ActiveRecord::Migration
	def change
		change_column :users, :stripe_recipient_id, :string
		change_column :users, :stripe_customer_id, :string
	end
end
