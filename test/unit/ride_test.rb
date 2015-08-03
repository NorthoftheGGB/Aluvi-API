require 'test_helper'

class RideTest < ActiveSupport::TestCase


	test "driver cancels scheduled fare by driver" do
		fare = FactoryGirl.create(:scheduled_fare)
		fare.cancel_ride_for_user(fare.driver)
		assert_equal("driver_cancelled", fare.state)
		assert_not_nil(fare.finished)
	end


	test "driver cancels scheduled fare" do
		fare = FactoryGirl.create(:scheduled_fare)
		fare.cancel_ride_for_user(fare.rides.where(driving:true).first.rider)
		assert_equal("driver_cancelled", fare.state)
		assert_not_nil(fare.finished)
	end

	test "cancel driver fare by ride" do
		fare = FactoryGirl.create(:scheduled_fare)
		fare.ride_cancelled!(fare.rides.where(driving:true).first)
		assert_equal("driver_cancelled", fare.state)
		assert_not_nil(fare.finished)
	end

	test "rider cancels single rider fare" do
		fare = FactoryGirl.create(:scheduled_fare)
		fare.cancel_ride_for_user(fare.rides.where(driving:false).first.rider)
		assert_equal("rider_cancelled", fare.state)
		assert_not_nil(fare.finished)
	end

	test "cancel single rider fare by ride" do
		fare = FactoryGirl.create(:scheduled_fare)
		fare.ride_cancelled!(fare.rides.where(driving: false).first)
		assert_equal("rider_cancelled", fare.state)
		assert_not_nil(fare.finished)
	end

	test "rider cancels multi rider fare" do
		fare = FactoryGirl.create(:scheduled_multirider_fare)
		fare.ride_cancelled!(fare.rides.where(driving: false).first)
		assert_equal("scheduled", fare.state)
		assert_nil(fare.finished)
	end

	test "both riders cancel multi rider fare" do
		Rails.logger.info "both riders cancel multi rider fare" 
		fare = FactoryGirl.create(:scheduled_multirider_fare)

		fare.rides.where(driving: false).each do |r|
			Rails.logger.info "cancelling one" 
			fare.ride_cancelled!(r)
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
