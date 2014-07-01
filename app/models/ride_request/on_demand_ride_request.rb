class OnDemandRideRequest < RideRequest

	def self.create( type, origin, destination, rider_id )
		ride_request = OnDemandRideRequest.new
		ride_request.request_type = type
		ride_request.origin = origin
		ride_request.destination = destination
		ride_request.user_id = rider_id
		ride_request
	end

	def self.create!( type, origin, destination, rider_id )
		ride_request = OnDemandRideRequest.create( type, origin, destination, rider_id )
		ride_request.save
		ride_request
	end

end
