class CommuterRide < Ride

	self.table_name = "rides"
	default_scope { where request_type: "commuter" }


	def self.create(origin, origin_place_name, destination, destination_place_name, pickup_time, driving, rider )
		ride = CommuterRide.new
		ride.request_type = "commuter"
		ride.origin = origin
		ride.origin_place_name = origin_place_name
		ride.destination = destination
		ride.destination_place_name = destination_place_name
		ride.pickup_time = pickup_time
		ride.driving = driving
		ride.rider = rider
		ride.requested_datetime = DateTime.now
		ride
	end

	def self.create!( origin, origin_place_name, destination, destination_place_name, pickup_time, driving, rider )
		ride = CommuterRide.create( origin, origin_place_name, destination, destination_place_name, pickup_time, driving, rider )
		ride.save
		ride
	end

	def return_ride 
		CommuterRide.where({ trip_id: self.trip_id, direction: 'b' }).first
	end

	def forward_ride 
		CommuterRide.where({ trip_id: self.trip_id, direction: 'a' }).first
	end

end
