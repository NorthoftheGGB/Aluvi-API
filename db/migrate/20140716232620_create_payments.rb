class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :fare_id
      t.integer :rider_id
      t.integer :driver_id
      t.string :stripe_customer_id
      t.string :stripe_charge_id
      t.integer :amount_cents
      t.string :string_charge_status
      t.string :initiation
      t.datetime :catpured_at

      t.timestamps
    end
  end
end
