class RideRequest < ActiveRecord::Base

	ON_DEMAND = :on_demand
	COMMUTER = :commuter

	belongs_to :user, inverse_of: :ride_requests
	belongs_to :ride, inverse_of: :ride_requests
  attr_accessible :destination, :destination_place_name, :origin, :origin_place_name, :requested_datetime, :state, :type

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

		event :schedule do
			transitions :from => :requested, :to => :scheduled
		end

	end

	def initialize( type )
		self.type = type
	end

	private
	def ride_requested
		notify_observers :requested # notifies scheduler
		if( type == RideRequest::ON_DEMAND )
			# go ahead and create the associated ride if it's on demand
			self.ride = Ride.new( Time.now, meeting_point, destination )
			ride.save
		end		

	end

end
