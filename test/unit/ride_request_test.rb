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
		FactoryGirl.create(:available_driver)	
		FactoryGirl.create(:available_driver)	

		ride_request = RideRequest.create(TransportType::ON_DEMAND,'POINT(-122 47)','POINT(-123 45)')
		ride_request.save
		ride_request.request!
		ride = ride_request.ride

		driver = User.available_drivers.first # from the factory calls above

		# offer the ride to the driver
		driver.offered_ride(ride)

		ride.accepted!(driver)
		
		offer = driver.offered_rides.where(:ride_id => ride.id).first
		assert_not_nil(offer)

		offer.accepted!

		assert_equal(ride.state, "scheduled")
		assert_equal(offer.state, "accepted")

	end

	test "driver declines ride" do
		FactoryGirl.create(:available_driver)	
		FactoryGirl.create(:available_driver)	
		ride_request = RideRequest.create(TransportType::ON_DEMAND,'POINT(-122 47)','POINT(-123 45)')
		ride_request.save
		ride_request.request!
		ride = ride_request.ride

		drivers = User.available_drivers
		drivers.each do |d|
			d.offered_ride(ride)
		end

		driver = drivers[0]
		offer = driver.offered_rides.where(:ride_id => ride.id).first
		offer.declined!
		offer2 = drivers[1].offered_rides.where(:ride_id => ride.id).first

		assert_equal("declined", offer.state)
		assert_equal("offered", offer2.state)
	end

	test "driver cancels scheduled ride" do
		ride = FactoryGirl.create(:scheduled_ride)
		ride.driver_cancelled!
		assert_equal("driver_cancelled", ride.state)
		assert_not_nil(ride.finished)
	end

	test "rider cancels single rider ride" do
		ride = FactoryGirl.create(:scheduled_ride)
		ride.rider_cancelled!(ride.riders.first)
		assert_equal("rider_cancelled", ride.state)
		assert_not_nil(ride.finished)
	end

	test "rider cancels multi rider ride" do
		ride = FactoryGirl.create(:scheduled_multirider_ride)
		ride.rider_cancelled!(ride.riders.first)
		assert_equal("scheduled", ride.state)
		assert_nil(ride.finished)
	end

	test "both riders cancel multi rider ride" do
		ride = FactoryGirl.create(:scheduled_multirider_ride)

		riders = Array.new
		ride.riders.each do |r|
			riders.push(r)
		end

		riders.each do |r|
			ride.rider_cancelled!(r)
		end
		assert_equal("rider_cancelled", ride.state)
		assert_not_nil(ride.finished)
	end


end
