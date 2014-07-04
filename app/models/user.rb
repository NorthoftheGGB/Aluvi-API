class User < ActiveRecord::Base
	has_many :ride_requests, :foreign_key => :user_id, :inverse_of => :user
	has_many :rider_rides, :foreign_key => :rider_id
	has_many :rides, through: :rider_rides
	has_many :driver_rides, :class_name => 'Ride', :foreign_key => :driver_id
	has_many :cars, :foreign_key => :driver_id, inverse_of: :driver
	has_many :devices
	# has_one :company, :foreign_key => :user_id
	has_many :offered_rides, :foreign_key => :driver_id  
	has_one :driver_role
	has_one :rider_role
  attr_accessible :commuter_balance_cents, :commuter_refill_amount_cents, :company_id, :first_name, :location, :last_name, :stripe_customer_id, :stripe_recipient_id, :salt, :token, :phone, :email, :driver_state, :rider_state

	scope :drivers, -> { joins(:driver_role).readonly(false) }
	scope :available_drivers, ->{ drivers.where(:driver_roles => {:state => :on_duty}) }

	self.rgeo_factory_generator = RGeo::Geographic.method(:spherical_factory)

	def self.new_driver
		user = User.new
		user.driver_role = DriverRole.new
		user.save!
		user
	end

	def self.authorize!(token)
		User.where( :token => token ).first
	end

	def self.user_with_phone(phone)
		user = User.where( :phone => phone).first
		if user.nil?
			user = User.new
			user.phone = phone
			user.save
		end
		user
	end

	def generate_token!
		self.token = loop do
			random_token = SecureRandom.hex(64)
			break random_token unless User.exists?(token: random_token)
		end
		save
		self.token
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
			if(self.salt.nil?)
				self.salt = SecureRandom.hex(32)
				save
			end
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
		self.offered_rides << offered_ride
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


	def rider_state
		unless self.rider_role.nil?
			self.rider_role.state
		end
	end

	def rider_state=(state_change)
		unless state_change.nil? || state_change == ''
			if state_change == :initialize
				self.rider_role = RiderRole.new
				self.rider_role.save
				save
			else
				self.rider_role.method(state_change).call
				self.rider_role.save
			end
		end
	end

	def driver_state
		unless self.driver_role.nil?
			return self.driver_role.state
		end
	end

	def driver_state=(state_change)
		unless state_change.nil? || state_change == ''
			if state_change == :initialize
				self.driver_role = DriverRole.new
				self.driver_role.save
				save
			else
				self.driver_role.method(state_change).call
				self.driver_role.save
			end
		end
	end

	# access
	def involved_in_ride ride
		if ride.riders.include? self || ride.driver == self
			true
		else
			false
		end
	end

	# convienience
	def full_name
		(self.first_name || "") + ' ' + (self.last_name || "")
	end

end
