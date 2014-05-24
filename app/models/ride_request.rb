class RideRequest < ActiveRecord::Base

	belongs_to :user, inverse_of: :ride_requests
	belongs_to :ride, inverse_of: :ride_requests
  attr_accessible :aasm_state, :destination, :destination_place_name, :origin, :origin_place_name, :requested_datetime, :state, :request_type

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

		event :cancel do
			transitions :from => :requested, :to => :cancelled
		end

		event :failed do
			transitions :fram => :requested, :to => :failed
		end

		event :scheduled do
			transitions :from => :requested, :to => :scheduled, :after => :notify_scheduled
		end

	end

	# By default, use the GEOS implementation for spatial columns.
	# This doesn't seem to be working correctly at the moment.
	self.rgeo_factory_generator = RGeo::Geos.method(:factory)
	set_rgeo_factory_for_column(:origin, RGeo::Geos.factory(srid: 4326))

	def self.create( type, origin, destination )
		ride_request = RideRequest.new
		ride_request.request_type = type
		ride_request.origin = origin
		ride_request.destination = destination
		ride_request
	end

	def self.create!( type, origin, destination )
		ride_request = RideRequest.create( type, origin, destination )
		ride_request.save
		ride_request
	end

	private
	def ride_requested
		if( request_type == TransportType::ON_DEMAND )
			# go ahead and create the associated ride if it's on demand
			self.ride = Ride.create( Time.now, origin, destination )
			self.ride.save
			save
		end		
		notify_observers :requested # notifies scheduler

	end

	def notify_scheduled
		notify_observers :scheduled
	end


end
