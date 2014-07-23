class CommuterRide < Ride

	self.table_name = "ride_requests"
	default_scope { where request_type: "commuter" }

	def self.create( type, origin, origin_place_name, destination, destination_place_name, desired_arrival, rider_id )
		ride_request = CommuterRide.new
		ride_request.request_type = type
		ride_request.origin = origin
		ride_request.origin_place_name = origin_place_name
		ride_request.destination = destination
		ride_request.destination_place_name = destination_place_name
		ride_request.desired_arrival = desired_arrival
		ride_request.user_id = rider_id
		ride_request.requested_datetime = DateTime.now
		ride_request
	end

	def self.create!( type, origin, origin_place_name, destination, destination_place_name, desired_arrival, rider_id )
		ride_request = CommuterRide.create( type, origin, origin_place_name, destination, destination_place_name, desired_arrival, rider_id )
		ride_request.save
		ride_request
	end

end
