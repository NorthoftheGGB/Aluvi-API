class OnDemandRide < Ride

	def self.create( origin, origin_place_name, destination, destination_place_name, rider )
		ride = OnDemandRide.new
		ride.request_type = 'on_demand'
		ride.origin = origin
		ride.origin_place_name = origin_place_name
		ride.destination = destination
		ride.destination_place_name = destination_place_name
		ride.rider = rider
		ride.requested_datetime = DateTime.now
		ride
	end

	def self.create!(origin, origin_place_name, destination, destination_place_name, rider )
		ride = OnDemandRide.create( origin, origin_place_name, destination, destination_place_name, rider )
		ride.save
		ride
	end

end
