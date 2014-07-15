class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :stripe_customer_id
      t.integer :stripe_recipient_id
      t.integer :company_id
      t.string :first_name
      t.string :last_name
      t.boolean :is_driver
      t.boolean :is_rider
      t.string :state
      t.integer :commuter_balance_cents
      t.integer :commuter_refill_amount_cents
      t.point :location, :geographic => true

      t.timestamps
    end
		change_table :users do |t|
			#		t.index :location, :spatial => true
		end
  end
end
