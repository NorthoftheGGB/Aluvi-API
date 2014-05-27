class User < ActiveRecord::Base
	has_many :ride_requests, :foreign_key => :rider_id, :inverse_of => :user
	has_many :rides, :through => "rider_rides", :foreign_key => :ride_id
	has_many :cars, :foreign_key => :driver_id, inverse_of: :users
	has_many :devices
	# has_one :company, :foreign_key => :user_id
	has_many :offered_rides, :foreign_key => :driver_id  
  attr_accessible :commuter_balance_cents, :commuter_refill_amount_cents, :company_id, :first_name, :is_driver, :is_rider, :location, :last_name, :state, :stripe_customer_id, :stripe_recipient_id

	scope :drivers, -> { where(is_driver: true) }
	scope :available_drivers, ->{ drivers.where(state: :driver_idle) }


	include AASM
	aasm_column :state
	aasm do 
		state :development, :initial => true
		state :driver_idle
	end

	def offered_ride( ride )
		offered_ride = OfferedRide.new
		offered_ride.ride = ride
		offered_rides << offered_ride
		save
	end

	def declined_ride( ride )
		offered_ride = offered_rides.where(:ride_id => ride.id).first
		offered_ride.declined!
	end

end
