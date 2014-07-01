class Ride < ActiveRecord::Base

	has_many :rider_rides
	has_many :riders, through: :rider_rides
	belongs_to :driver, :class_name => 'User'
	has_many :ride_requests, inverse_of: :ride
	has_many :offers, :class_name => 'OfferedRide', inverse_of: :ride
	belongs_to :car, inverse_of: :rides
  attr_accessible :destination, :destination_place_name, :finished, :meeting_point, :meeting_point_place_name, :pickup_time, :scheduled, :started, :state

	self.rgeo_factory_generator = RGeo::Geographic.method(:spherical_factory)

	include AASM
	aasm_column :state

	aasm do
		state :unscheduled, :initial => true
		state :retracted_by_rider
		state :scheduled
		state :rider_cancelled
		state :started
		state :driver_cancelled
		state :completed

		event :retracted_by_rider do
			transitions :from => :unscheduled, :to => :retracted_by_rider
		end

		event :schedule do
			transitions :from => :unscheduled, :to => :scheduled, :on_transition => :schedule_ride
		end
		
		event :accepted do
			transitions :from => :unscheduled, :to => :scheduled
		end

		event :assign do
			transitions :from => :unscheduled, :to => :scheduled
		end

		event :rider_cancelled do
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
	alias aasm_assign assign
	alias aasm_assign! assign!
	alias aasm_rider_cancelled rider_cancelled
	alias aasm_rider_cancelled! rider_cancelled!
	alias aasm_pickup pickup
	alias aasm_pickup! pickup!
	alias aasm_retracted_by_rider retracted_by_rider
	alias aasm_retracted_by_rider! retracted_by_rider!
 
	def self.create ( pickup_time, meeting_point, meeting_point_place_name, destination, destination_place_name )
		ride = Ride.new
		ride.pickup_time = pickup_time
		ride.meeting_point = meeting_point
		ride.meeting_point_place_name = meeting_point_place_name
		ride.destination = destination
		ride.destination_place_name = destination_place_name
		ride
	end

	def is_cancelled
		if(state == 'driver_cancelled' || state == 'rider_cancelled')
			true
		else
			false
		end
	end

	def accepted( driver )
		aasm_accepted
		Rails.logger.debug 'driver accepted ride'
		schedule_driver(driver)
	end

	def accepted!( driver )
		accepted(driver)
		save
	end

	def assign(driver)
		aasm_assign
		schedule_driver(driver)
	end

	def assign!(driver)
		assign(driver)
		save
	end

	def schedule_driver(driver)
		self.driver = driver	
		Rails.logger.debug "not currently setting car for ride"
		# self.car = driver.car
		# and mark all ride requests as scheduled
		update_ride_requests_to_scheduled
		# and mark all ride offers as closed 
		offers.open_offers.each do |offer|
			offer.closed!
		end
		notify_scheduled
	end

	def retracted_by_rider! rider
		retracted_by_rider rider
		save
	end

	def retracted_by_rider rider
		if( riders.count == 1 )
			aasm_retracted_by_rider
			self.finished = Time.now
			offers.open_offers.each do |offer|
				offer.closed!
			end
			notify_observers :retracted
		else
			riders.delete(rider)
		end
	end

	
	def rider_cancelled rider
		if( riders.count == 1 ) 
			# this is the only rider, cancel the whole ride
			aasm_rider_cancelled
			self.finished = Time.now
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

	def driver_cancelled_ride
		self.finished = Time.now
		save
		notify_observers :ride_cancelled_by_driver
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
		notify_observers :ride_completed
	end

	def notify_scheduled
		Rails.logger.debug "in notify_scheduled"
		notify_observers :scheduled
	end

	def notify_ride_cancelled_by_rider
		notify_observers :ride_cancelled_by_rider
	end

	def notify_ride_cancelled_by_driver
		notify_observers :ride_cancelled_by_driver
	end

	def update_ride_requests_to_scheduled
		ride_requests.each do |rr|
			rr.scheduled
		end
	end

	  
end
