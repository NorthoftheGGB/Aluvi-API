class Ride < ActiveRecord::Base

	has_many :riders, :class_name => 'User', :through => :rider_rides
	has_one :driver, :class_name => 'User', :foreign_key => 'driver_id'
	has_many :ride_requests, inverse_of: :ride
	belongs_to :car, inverse_of: :rides
  attr_accessible :destination, :destination_place_name, :finished, :meeting_point, :meeting_point_place_name, :scheduled, :started, :state

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
 
	def initialize ( meeting_point, destination )
		# set ride_request(s) ?
		self.meeting_point = meeting_point
		self.destination = destination
	end
	
	private
	def schedule_ride( pickup_time, driver, car )
		self.pickup_time = pickup_time
		self.driver = driver
		self.car = car
		self.scheduled = Time.now
		save
	end

	def rider_cancelled_ride
		self.finished = Time.now
	end

	def driver_cancelled_ride
		self.inished = Time.now
	end

	def started_ride
		self.started = Time.now
	end

	def completed_ride
		self.finished = Time.now
	end

	def notify_scheduled
		notify_observers :scheduled
	end
	  
end
