class Payment < ActiveRecord::Base
  attr_accessible :amount_cents, :driver_earnings_cents, :captured_at, :driver_id, :fare_id, :initiation, :rider_id, :ride_id, :stripe_charge_status, :stripe_charge_id, :stripe_customer_id, :paid
	belongs_to :fare, :class_name => 'Fare', :foreign_key => :fare_id # new lexicon
	belongs_to :ride, :class_name => 'RideRequest', :foreign_key => :ride_id # new lexicon
	belongs_to :rider, :class_name => 'User'
	belongs_to :driver, :class_name => 'Driver'

end
