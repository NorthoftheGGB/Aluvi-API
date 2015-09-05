class CreateReceipts < ActiveRecord::Migration
  def change
    create_table :receipts do |t|
      t.string :type
      t.integer :amount

      t.timestamps null: false
    end
  end
end
