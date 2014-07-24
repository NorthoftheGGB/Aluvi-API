class Ride < ActiveRecord::Base

	belongs_to :rider, inverse_of: :rides
	belongs_to :fare, inverse_of: :rides
  attr_accessible :aasm_state, :rider_id, :destination, :destination_place_name, :origin, :origin_place_name, :requested_datetime, :state, :request_type, :desired_arrival

	self.rgeo_factory_generator = RGeo::Geographic.spherical_factory( :srid => 4326 )

	include AASM
	aasm_column :state

	aasm do
		state :created, :initial => true
		state :requested
		state :scheduled
		state :cancelled
		state :failed

		event :request, :after => :ride_requested do
			transitions :from => :created, :to => :requested
		end

		event :cancel, :after => :request_cancelled do
			transitions :from => :requested, :to => :cancelled
		end

		event :failed do
			transitions :fram => :requested, :to => :failed
		end

		event :scheduled, :after => :notify_scheduled do
			transitions :from => :requested, :to => :scheduled
		end

	end


	def route_description
		route = ''
		unless self.origin_place_name.nil?
			route += self.origin_place_name 
		else
			route += 'unspecified'
		end
		route += ' to '
		unless self.destination_place_name.nil?
			route += self.destination_place_name
		else
			route += 'unspecified'
		end
	end

	private
	def ride_requested
		if( request_type == TransportType::ON_DEMAND )
			# go ahead and create the associated ride if it's on demand
			self.fare = Fare.create( Time.now, origin, origin_place_name, destination, destination_place_name )
			self.fare.meeting_point = origin
			self.fare.meeting_point_place_name = origin_place_name
			self.fare.riders << self.rider
			self.fare.save
			save
		elsif( request_type == TransportType::COMMUTER )

		end		
		notify_observers :requested # notifies scheduler

	end

	def request_cancelled
		if self.fare != nil && self.fare.unscheduled?
			self.fare.retracted_by_rider! self.user
		end
	end

	def notify_scheduled
		notify_observers :scheduled
	end

end
