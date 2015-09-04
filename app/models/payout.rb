class Payout < ActiveRecord::Base
  attr_accessible :amount_cents, :date, :driver_id, :stripe_transfer_id, :stripe_transfer_status
	
	belongs_to :driver
end
