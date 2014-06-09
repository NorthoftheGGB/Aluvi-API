class User < ActiveRecord::Base
	has_many :ride_requests, :foreign_key => :rider_id, :inverse_of => :user
	has_many :rider_rides, :foreign_key => :rider_id
	has_many :rides, through: :rider_rides
	has_many :cars, :foreign_key => :driver_id, inverse_of: :users
	has_many :devices
	# has_one :company, :foreign_key => :user_id
	has_many :offered_rides, :foreign_key => :driver_id  
	has_one :driver_role
	has_one :rider_role

  attr_accessible :commuter_balance_cents, :commuter_refill_amount_cents, :company_id, :first_name, :is_driver, :is_rider, :location, :last_name, :stripe_customer_id, :stripe_recipient_id, :salt, :token, :phone, :email

	scope :drivers, -> { where(is_driver: true) }
	scope :available_drivers, ->{ drivers.joins(:driver_role).where(:state => :on_duty) }

	self.rgeo_factory_generator = RGeo::Geographic.method(:spherical_factory)

	# this state machine is for driver state
	#include AASM
	#aasm_column :state
	#aasm do 
	#	state :development, :initial => true
	#	state :driver_idle
	#	state :driver_clocked_off
	#	state :busy
	#end

	def self.user_with_email(email)
		user = User.where( :email => email).first
		if user.nil?
			user = User.new
			user.email = email
			user.save
		end
		user
	end

	def interested_in_driving
		if self.driver_role.nil?
			self.driver_role = DriverRole.new
			save
		end
	end

	def registered_for_riding
		if self.rider_role.nil?
			self.rider_role = RiderRole.new
			save
		end
	end


	# authentication
	def hash_password(password)
			salted_password = self.salt + password
			Digest::SHA2.hexdigest salted_password
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
		self.location = RGeo::Geographic.spherical_factory.point(longitude, latitude)
		save
	end

end
