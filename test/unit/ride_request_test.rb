require 'test_helper'

class RideRequestTest < ActiveSupport::TestCase

	# disable the transactions if we want to, just for fun
	# self.use_transactional_fixtures = false
	
	test "request on demand ride" do
		ride_request = RideRequest.create(TransportType::ON_DEMAND,'POINT(-122 47)','POINT(-123 45)')
		ride_request.save
		ride_request.request!

		ride = ride_request.ride
		assert_not_nil(ride, "Ride should not be nil" )
		assert_not_nil(ride.meeting_point, "Ride should have origin" )
		assert_not_nil(ride.destination, "Ride should have destination" )
	end

	test "driver accepts ride" do
		ride_request = RideRequest.create(TransportType::ON_DEMAND,'POINT(-122 47)','POINT(-123 45)')
		ride_request.save
		ride_request.request!
		ride = ride_request.ride

		driver = User.available_drivers.first # this is where the fixtures come in

		# offer the ride to the driver
		driver.offered_ride(ride)

		ride.accepted!(driver)

		assert_equal(ride.state, "scheduled")
		
		offer = driver.offered_rides.where(:ride_id => ride.id).first
		assert_not_nil(offer)

		offer.accepted!

		assert_equal(offer.state, "accepted")

	end


end
