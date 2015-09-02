class AddDateToReceipts < ActiveRecord::Migration
  def change
    add_column :receipts, :date, :datetime
  end
end
