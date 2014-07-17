class FixStripeChargeStatusColumnName < ActiveRecord::Migration
  def change
		   rename_column :payments, :string_charge_status, :stripe_charge_status
  end
end
