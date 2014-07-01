class CommuterRideRequest < RideRequest

	self.table_name = "ride_requests"
	default_scope { where request_type: "commuter" }

	def self.create( type, origin, destination, desired_arrival, rider_id )
		ride_request = CommuterRideRequest.new
		ride_request.request_type = type
		ride_request.origin = origin
		ride_request.destination = destination
		ride_request.desired_arrival = desired_arrival
		ride_request.user_id = rider_id
		ride_request
	end

	def self.create!( type, origin, destination, desired_arrival, rider_id )
		ride_request = CommuterRideRequest.create( type, origin, destination, desired_arrival, rider_id )
		ride_request.save
		ride_request
	end

end
