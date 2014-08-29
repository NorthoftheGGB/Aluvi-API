require 'test_helper'

class RideTest < ActiveSupport::TestCase

	test "request on demand ride" do
		rider = FactoryGirl.create(:rider)
		ride = OnDemandRide.create!(
																RGeo::Geographic.spherical_factory( :srid => 4326 ).point(-122, 47),
																'place name',
																RGeo::Geographic.spherical_factory( :srid => 4326 ).point(-122, 47),
																'place_name',
																rider
															 )
		ride.save
		ride.request!

		fare = ride.fare
		assert_not_nil(fare, "Ride should not be nil" )
		assert_not_nil(fare.meeting_point, "Ride should have origin" )
		assert_not_nil(fare.drop_off_point, "Ride should have destination" )
	end

	test "driver accepts fare" do
		FactoryGirl.create(:available_driver)	
		FactoryGirl.create(:available_driver)	
		rider = FactoryGirl.create(:rider)

		ride = OnDemandRide.create!(
																RGeo::Geographic.spherical_factory( :srid => 4326 ).point(-122, 47),
																'place name',
																RGeo::Geographic.spherical_factory( :srid => 4326 ).point(-122, 47),
																'place_name',
																rider
															 )
		ride.save
		ride.save
		ride.request!
		fare = ride.fare

		driver = Driver.available_drivers.first # from the factory calls above

		# offer the fare to the driver
		driver.offer_fare(fare)
		offer = driver.offers.where(:fare_id => fare.id).first
		assert_not_nil(offer)

		offer.accepted!

		fare.accepted!(driver)
	
		assert_equal("scheduled", fare.state)
		assert_equal("accepted", offer.state)

	end

	test "driver declines fare" do
		FactoryGirl.create(:available_driver)	
		FactoryGirl.create(:available_driver)	
		rider = FactoryGirl.create(:rider)

		ride = OnDemandRide.create!(
																RGeo::Geographic.spherical_factory( :srid => 4326 ).point(-122, 47),
																'place name',
																RGeo::Geographic.spherical_factory( :srid => 4326 ).point(-122, 47),
																'place_name',
																rider
															 )
		ride.save
		ride.request!
		fare = ride.fare

		drivers = Driver.available_drivers
		drivers.each do |d|
			d.offer_fare(fare)
		end

		driver = drivers[0]
		offer = driver.offers.where(:fare_id => fare.id).first
		offer.declined!
		offer2 = drivers[1].offers.where(:fare_id => fare.id).first

		assert_equal("declined", offer.state)
		assert_equal("offered", offer2.state)
	end

	test "driver cancels scheduled fare" do
		fare = FactoryGirl.create(:scheduled_fare)
		fare.driver_cancelled!
		assert_equal("driver_cancelled", fare.state)
		assert_not_nil(fare.finished)
	end

	test "rider cancels single rider fare" do
		fare = FactoryGirl.create(:scheduled_fare)
		fare.rider_cancelled!(fare.riders.first)
		assert_equal("rider_cancelled", fare.state)
		assert_not_nil(fare.finished)
	end

	test "rider cancels multi rider fare" do
		fare = FactoryGirl.create(:scheduled_multirider_fare)
		fare.rider_cancelled!(fare.riders.first)
		assert_equal("scheduled", fare.state)
		assert_nil(fare.finished)
	end

	test "both riders cancel multi rider fare" do
		Rails.logger.info "both riders cancel multi rider fare" 
		fare = FactoryGirl.create(:scheduled_multirider_fare)

		riders = Array.new
		fare.riders.each do |r|
			riders.push(r)
		end
		Rails.logger.info "riders count"
		Rails.logger.info fare.riders.count
		Rails.logger.info riders

		riders.each do |r|
			fare.rider_cancelled!(r)
		end
		assert_equal("rider_cancelled", fare.state)
		assert_not_nil(fare.finished)
	end

	test "rider picked up" do
		fare = FactoryGirl.create(:scheduled_fare)
		fare.pickup!

		assert_equal("started", fare.state)
		assert_not_nil(fare.started)

	end

	test "arrival" do

		fare = FactoryGirl.create(:scheduled_fare)
		fare.pickup!
		fare.arrived!

		assert_equal("completed", fare.state)
		assert_not_nil(fare.finished)

	end


end
