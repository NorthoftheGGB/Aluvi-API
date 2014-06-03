class User < ActiveRecord::Base
	has_many :ride_requests, :foreign_key => :rider_id, :inverse_of => :user
	has_many :rides, :through => "rider_rides", :foreign_key => :ride_id
	has_many :cars, :foreign_key => :driver_id, inverse_of: :users
	has_many :devices
	# has_one :company, :foreign_key => :user_id
	has_many :offered_rides, :foreign_key => :driver_id  
	# TODO: these can be used to track onboarding state
	#	has_one :driver_state
	#	has_one :rider_state

  attr_accessible :commuter_balance_cents, :commuter_refill_amount_cents, :company_id, :first_name, :is_driver, :is_rider, :location, :last_name, :state, :stripe_customer_id, :stripe_recipient_id, :rider_location

	scope :drivers, -> { where(is_driver: true) }
	scope :available_drivers, ->{ drivers.where(state: :driver_idle) }

	self.rgeo_factory_generator = RGeo::Geographic.method(:spherical_factory)

	# this state machine is for driver state
	include AASM
	aasm_column :state
	aasm do 
		state :development, :initial => true
		state :driver_idle
		state :driver_clocked_off
		state :busy
	end

	#
	# driver model
	#
	def offer_ride( ride )
		offered_ride = OfferedRide.new
		offered_ride.ride = ride
		offered_ride.ride.save
		offered_rides << offered_ride
		save
		offered_ride
	end

	def offer_for_ride( ride )
		offered_ride = OfferedRide.where(:driver_id => id).where(:ride_id => ride.id).first
	end

	def declined_ride( ride )
		offer_for_ride(ride).declined!
	end

	def accepted_ride( ride )
		offer_for_ride(ride).accepted!
		ride.accepted!(self)
	end

	#
	# rider model
	# 
	def update_location!(longitude, latitude)
		self.rider_location = RGeo::Geographic.spherical_factory.point(longitude, latitude)
		save
	end

	# convience method
	def location
		return self.rider_location
	end



end
