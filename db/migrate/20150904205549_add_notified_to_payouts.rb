class AddNotifiedToPayouts < ActiveRecord::Migration
  def change
    add_column :payouts, :notified, :boolean, :default => false
  end
end
