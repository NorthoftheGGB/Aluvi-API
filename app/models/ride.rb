class Ride < ActiveRecord::Base

	has_many :rider_rides
	has_many :riders, through: :rider_rides, :class_name => 'User'
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
		state :completed

		event :schedule do
			transitions :from => :created, :to => :scheduled, :on_transition => :schedule_ride, :after => :notify_scheduled
		end
		
		event :accepted do
			transitions :from => :created, :to => :scheduled, :after => :notify_scheduled # :on_transition => :driver_accepted_ride, 
		end

		event :rider_cancelled, :after => :rider_cancelled_ride do
			transitions :from => :scheduled, :to => :rider_cancelled
		end

		event :driver_cancelled, :after => :driver_cancelled_ride do
			transitions :from => :scheduled, :to => :driver_cancelled
			transitions :from => :started, :to => :driver_cancelled
		end

		event :pickup, :after => :started_ride do
			transitions :from => :scheduled, :to => :started
			transitions :from => :started, :to => :started
		end

		event :arrived, :after => :completed_ride do
			transitions :from => :started, :to => :completed
		end
		
	end

	alias aasm_accepted accepted
	alias aasm_accepted! accepted!
	alias aasm_rider_cancelled rider_cancelled
	alias aasm_rider_cancelled! rider_cancelled!
	alias aasm_pickup pickup
	alias aasm_pickup! pickup!
 
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
	
	def rider_cancelled rider
		if( riders.count == 1 ) 
			# this is the only rider, cancel the whole ride
			aasm_rider_cancelled
			rider_cancelled_ride
			notify_ride_cancelled_by_rider
		else 
			riders.delete(rider)

		end
	end

	def rider_cancelled! rider
		rider_cancelled rider
		save
	end

	def pickup(rider = nil) 
		aasm_pickup
		unless(rider.nil?)
			# TODO extend model to record which rider was picked up in a multirider ride	
		end

	end

	def pickup!(rider = nil)
		pickup(rider)
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
	end

	def driver_cancelled_ride
		self.finished = Time.now
		save
	end

	def rider_cancelled_ride
		self.finished = Time.now
	end

	def started_ride
		if(@started.nil?)
			self.started = Time.now
		end
		save
	end

	def completed_ride
		self.finished = Time.now
		save
	end

	def notify_scheduled
		notify_observers :scheduled
	end

	def notify_ride_cancelled_by_rider
		notify_observers :ride_cancelled_by_rider
	end

	def notify_ride_cancelled_by_driver
		notify_observers :ride_cancelled_by_driver
	end

	def notify_rider_cancelled_by_rider
		notify_observers :ride_cancelled_by_rider
	end


	def update_ride_requests_to_scheduled
		ride_requests.each do |rr|
			rr.scheduled
		end
	end
	  
end
