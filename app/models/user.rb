class User < ActiveRecord::Base
	has_many :ride_requests, :foreign_key => :rider_id, :inverse_of => :user
	has_many :rides, :through => "rider_rides", :foreign_key => :rider_id
	has_many :cars, :foreign_key => :driver_id, inverse_of: => :user
	has_many :devices
	# has_one :company, :foreign_key => :user_id
  attr_accessible :commuter_balance_cents, :commuter_refill_amount_cents, :company_id, :first_name, :is_driver, :is_rider, :location, :last_name, :state, :stripe_customer_id, :stripe_recipient_id

	include AASM
	field :state

end
