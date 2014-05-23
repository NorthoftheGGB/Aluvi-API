require 'test_helper'

class RideRequestTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
	#
	
	test "request on demand ride" do
		ride_request = RideRequest.create(TransportType::ON_DEMAND,'POINT(-122 47)','POINT(-123 45)')
		ride_request.save
		ride_request.request!

		ride = ride_request.ride
		assert_not_nil(ride, "Ride should not be nil" )
		assert_not_nil(ride.meeting_point, "Ride should have origin" )
		assert_not_nil(ride.destination, "Ride should have destination" )
	end


end
