class Fare < ActiveRecord::Base

	belongs_to :driver, inverse_of: :fares
	belongs_to :car, inverse_of: :fares
	has_many :rider_fares
	has_many :riders, through: :rider_fares
	has_many :rides, inverse_of: :fare
	has_many :offers, inverse_of: :fare
	has_many :payments

  attr_accessible :drop_off_point, :drop_off_point_place_name, :finished, :meeting_point, :meeting_point_place_name, :pickup_time, :scheduled, :started, :state

	scope :active, -> { where( :state => [ :scheduled, :started ] ) }

	self.rgeo_factory_generator = RGeo::Geographic.spherical_factory( :srid => 4326 )

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

		event :schedule, :after => :ride_was_scheduled do
			transitions :from => :unscheduled, :to => :scheduled , :on_transition => Proc.new {|obj, *args| obj.schedule_ride(*args)}
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

	def self.assemble_ride_from_requests requests_arg

		Rails.logger.debug requests_arg
		requests = Array.new
		requests_arg.each do |r|
			if(r.is_a? Integer)
				requests << Ride.find(r)
			elsif (r.is_a? String)
				requests << Ride.find(r.to_i)
			else
				requests << r	
			end
		end
		Rails.logger.debug requests

		meeting_point_latitude = 0
		meeting_point_longitude = 0
		drop_off_point_latitude = 0
		drop_off_point_longitude = 0
		requests.each do |request|
			meeting_point_latitude += request.origin.latitude
			meeting_point_longitude += request.origin.longitude
			drop_off_point_latitude += request.destination.latitude
			drop_off_point_longitude += request.destination.longitude
		end
		meeting_point_latitude = meeting_point_latitude / requests.size
		meeting_point_longitude = meeting_point_longitude / requests.size
		drop_off_point_latitude = drop_off_point_latitude / requests.size
		drop_off_point_longitude = drop_off_point_longitude / requests.size
		ride = self.create( nil, 
								RGeo::Geographic.spherical_factory( :srid => 4326 ).point(meeting_point_longitude, meeting_point_latitude),
								"unnamed location",
								RGeo::Geographic.spherical_factory( :srid => 4326 ).point(drop_off_point_longitude, drop_off_point_latitude),
								"unnamed location");
		requests.each do |request|
			ride.rides << request
			ride.riders << request.user
		end
		ride.save
		ride

	end
 
	def self.create ( pickup_time, meeting_point, meeting_point_place_name, drop_off_point, drop_off_point_place_name )
		ride = Fare.new
		ride.pickup_time = pickup_time
		ride.meeting_point = meeting_point
		ride.meeting_point_place_name = meeting_point_place_name
		ride.drop_off_point = drop_off_point
		ride.drop_off_point_place_name = drop_off_point_place_name
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
		assign_driver(driver)
	end

	def accepted!( driver )
		accepted(driver)
		save
	end

	def assign(driver)
		aasm_assign
		assign_driver(driver)
	end

	def assign!(driver)
		assign(driver)
		save
	end

	def assign_driver(driver)
		self.driver = driver	
		self.car = driver.cars.first
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
		Rails.logger.info "RIDER_CANCELLED: riders count"
		Rails.logger.info self.riders
		Rails.logger.info self.riders.count
		if( self.riders.count == 1 ) 
			Rails.logger.info 'last rider cancelled ' + rider.id.to_s
			# this is the only rider, cancel the whole ride
			aasm_rider_cancelled
			self.finished = Time.now
			notify_fare_cancelled_by_rider
		else 
			Rails.logger.info 'RIDER_CANCELLED: one rider cancelled'
			self.riders.delete(rider)
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
		Rails.logger.debug 'pickup'
		pickup(rider)
		save
	end

	def schedule_ride( pickup_time, driver, car )
		self.pickup_time = pickup_time
		self.driver = driver
		self.car = car
		self.scheduled = Time.now
		save
	end

	def cost
		unless self.started.nil?
			cost = 250 # base
			unless self.finished.nil?
				minutes = (Time.parse(self.finished.to_s) - Time.parse(self.started.to_s)) / 60
			else 
				minutes = (Time.now - Time.parse(self.started.to_s)) / 60
			end
			minutes = minutes.to_i
			cost = cost + 25 * minutes
			#miles
			cost
		end
	end

	def cost_per_rider
		unless self.cost.nil?
			self.cost / self.riders.count
		end
	end

	def to_s
		"ride: { " + self.id.to_s + " } " 
	end

	def route_description
		self.meeting_point_place_name + " to " + self.drop_off_point_place_name
	end

	private
	def ride_was_scheduled 
		update_ride_requests_to_scheduled
		notify_scheduled
		notify_observers :driver_assigned
	end

	def driver_cancelled_ride
		self.finished = Time.now
		save
		self.driver.current_fare = nil
		self.driver.save
		notify_observers :fare_cancelled_by_driver
	end


	def started_ride
		Rails.logger.debug 'started_ride callback'
		if(@started.nil?)
			self.started = Time.now
		end
		Rails.logger.debug self.driver_id
		self.driver.current_fare_id = self.id
		Rails.logger.debug 'after current fare thing'
		self.driver.save
		Rails.logger.debug 'ended started_ride callback'
		save
	end

	def completed_ride
		self.finished = Time.now
		save
		self.driver.current_fare = nil
		self.driver.save
		notify_observers :fare_completed
	end

	def notify_scheduled
		Rails.logger.debug "in notify_scheduled"
		notify_observers :scheduled
	end

	def notify_fare_cancelled_by_rider
		notify_observers :fare_cancelled_by_rider
	end

	def notify_fare_cancelled_by_driver
		notify_observers :fare_cancelled_by_driver
	end

	def update_ride_requests_to_scheduled
		rides.each do |rr|
			rr.scheduled!
		end
	end

  
end
