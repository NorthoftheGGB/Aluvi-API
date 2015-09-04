class AddNotifiedToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :notified, :boolean, :default => false
  end
end
