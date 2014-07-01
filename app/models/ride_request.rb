class RideRequest < ActiveRecord::Base

	belongs_to :user, inverse_of: :ride_requests
	belongs_to :ride, inverse_of: :ride_requests
  attr_accessible :aasm_state, :user_id, :destination, :destination_place_name, :origin, :origin_place_name, :requested_datetime, :state, :request_type, :desired_arrival

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

	self.rgeo_factory_generator = RGeo::Geographic.method(:spherical_factory)

	private
	def ride_requested
		if( request_type == TransportType::ON_DEMAND )
			# go ahead and create the associated ride if it's on demand
			self.ride = Ride.create( Time.now, origin, destination )
			rider = User.find(user_id)
			self.ride.riders << rider
			self.ride.save
			save
		elsif( request_type == TransportType::COMMUTER )

		end		
		notify_observers :requested # notifies scheduler

	end

	def request_cancelled
		if self.ride != nil && self.ride.unscheduled?
			self.ride.retracted_by_rider! self.user
		end
	end

	def notify_scheduled
		notify_observers :scheduled
	end


end
