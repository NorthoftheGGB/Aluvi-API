class Ride < ActiveRecord::Base

	has_many :riders, :class_name => 'User', :through => :rider_rides
	belongs_to :driver, :class_name => 'User'
	has_many :ride_requests, inverse_of: :ride
	belongs_to :car, inverse_of: :rides
  attr_accessible :destination, :destination_place_name, :finished, :meeting_point, :meeting_point_place_name, :pickup_time, :scheduled, :started, :state

	include AASM
	aasm_column :state

	aasm do
		state :created, :initial => true
		state :scheduled
		state :rider_cancelled
		state :started
		state :driver_cancelled
		state :complete

		event :schedule do
			transitions :from => :created, :to => :scheduled, :on_transition => :schedule_ride, :after => :notify_scheduled
		end
		
		event :accepted do
			transitions :from => :created, :to => :scheduled, :after => :notify_scheduled # :on_transition => :driver_accepted_ride, 
		end

		event :rider_cancelled do
			transitions :from => :scheduled, :to => :rider_cancelled, :after => :rider_cancelled_ride
		end

		event :driver_cancelled do
			transitions :from => :scheduled, :to => :driver_cancelled, :after => :driver_cancelled_ride
			transitions :from => :started, :to => :driver_cancelled, :after => :driver_cancelled_ride
		end

		event :pickup do
			transitions :from => :scheduled, :to => :started, :after => :started_ride
		end

		event :arrived do
			transitions :from => :started, :to => :completed, :after => :completed_ride
		end
		
	end

	alias aasm_accepted accepted
	alias aasm_accepted! accepted!
	alias aasm_driver_cancelled driver_cancelled
	alias aasm_driver_cancelled! driver_cancelled!
 
	def self.create ( pickup_time, meeting_point, destination )
		ride = Ride.new
		ride.pickup_time = pickup_time
		ride.meeting_point = meeting_point
		ride.destination = destination
		ride
	end

	def accepted( driver )
		aasm_accepted
		driver_accepted_ride( driver )
		# and mark all ride requests as scheduled
		update_ride_requests_to_scheduled
	end

	def accepted!( driver )
		accepted(driver)
		save
	end
	
	def driver_cancelled( driver )
		aasm_driver_cancelled
		driver_cancelled_ride( driver )
	end

	def driver_cancelled!( driver )
		aasm_driver_cancelled
		driver_cancelled_ride( driver )
		save
	end
	
	private
	def schedule_ride( pickup_time, driver, car )
		self.pickup_time = pickup_time
		self.driver = driver
		self.car = car
		self.scheduled = Time.now
		save
	end

	def driver_accepted_ride( driver )
		Rails.logger.debug 'on transition driver accepted ride'
		self.driver = driver	
		Rails.logger.debug "driver_accepted_ride: not currently setting car for ride"
		# self.car = driver.car
		save
	end

	def driver_cancelled_ride( driver )
		self.driver = driver	
		# self.car = driver.car
		save
	end

	def rider_cancelled_ride
		@finished = Time.now
	end

	def driver_cancelled_ride
		@inished = Time.now
	end

	def started_ride
		@started = Time.now
	end

	def completed_ride
		@finished = Time.now
	end

	def notify_scheduled
		notify_observers :scheduled
	end

	def update_ride_requests_to_scheduled
		ride_requests.each do |rr|
			rr.scheduled
		end
	end
	  
end
