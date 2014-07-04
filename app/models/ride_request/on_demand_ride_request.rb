class OnDemandRideRequest < RideRequest

	def self.create( type, origin, origin_place_name, destination, destination_place_name, rider_id )
		ride_request = OnDemandRideRequest.new
		ride_request.request_type = type
		ride_request.origin = origin
		ride_request.origin_place_name = origin_place_name
		ride_request.destination = destination
		ride_request.destination_place_name = destination_place_name
		ride_request.user_id = rider_id
		ride_request.requested_datetime = DateTime.now
		ride_request
	end

	def self.create!( type, origin, origin_place_name, destination, destination_place_name, rider_id )
		ride_request = OnDemandRideRequest.create( type, origin, origin_place_name, destination, destination_place_name, rider_id )
		ride_request.save
		ride_request
	end

end
