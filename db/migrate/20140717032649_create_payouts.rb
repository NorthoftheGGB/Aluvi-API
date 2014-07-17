class CreatePayouts < ActiveRecord::Migration
  def change
    create_table :payouts do |t|
      t.integer :driver_id
      t.datetime :date
      t.integer :amount_cents

      t.timestamps
    end
  end
end
