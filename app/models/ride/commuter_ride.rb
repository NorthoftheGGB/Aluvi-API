class CommuterRide < Ride

	self.table_name = "rides"
	default_scope { where request_type: "commuter" }

	def self.create(origin, origin_place_name, destination, destination_place_name, desired_arrival, rider )
		ride = CommuterRide.new
		ride.request_type = "commuter"
		ride.origin = origin
		ride.origin_place_name = origin_place_name
		ride.destination = destination
		ride.destination_place_name = destination_place_name
		ride.desired_arrival = desired_arrival
		ride.rider = rider
		ride.requested_datetime = DateTime.now
		ride
	end

	def self.create!( origin, origin_place_name, destination, destination_place_name, desired_arrival, rider )
		ride = CommuterRide.create( type, origin, origin_place_name, destination, destination_place_name, desired_arrival, rider )
		ride.save
		ride
	end

end
