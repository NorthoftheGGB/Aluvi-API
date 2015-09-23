require 'rails_helper'

describe RidesAPIV2 do

	include AuthHelper

	before { RidesAPIV2.before { env["api.tilt.root"] = "app/views/api" } }

  let(:home_pickup) {DateTime.now.in_time_zone("Pacific Time (US & Canada)").change(hour: 7, min: 0, sec: 0) + 1.days}
  let(:work_pickup) {DateTime.now.in_time_zone("Pacific Time (US & Canada)").change(hour: 5+12, min: 0, sec: 0) + 1.days}

	describe "POST /api/v2/rides/commute" do
		it "creates new commuter ride requests" do
      @rider = FactoryGirl.create(:rider)
      post "/api/v2/rides/commute", {:type => 'commuter',:departure_latitude => 45.5,
                                  :departure_longitude => -122.3, :departure_place_name => "My House",
                                  :destination_latitude => 46.5, :destination_longitude => -122.4,
                                  :destination_place_name => 'My Work', 'departure_pickup_time' => home_pickup,
																	:return_pickup_time => work_pickup }, {'HTTP_AUTHORIZATION' => encode_credentials(@rider.token)}
      expect(response.status).to eq(200)
		end

		it "does not create new commuter ride requests when one exists in the future" do
      @rider = FactoryGirl.create(:rider)
      post "/api/v2/rides/commute", {:type => 'commuter',:departure_latitude => 45.5,
                                  :departure_longitude => -122.3, :departure_place_name => "My House",
                                  :destination_latitude => 46.5, :destination_longitude => -122.4,
                                  :destination_place_name => 'My Work', 'departure_pickup_time' => home_pickup,
																	:return_pickup_time => work_pickup }, {'HTTP_AUTHORIZATION' => encode_credentials(@rider.token)}
      post "/api/v2/rides/commute", {:type => 'commuter',:departure_latitude => 45.5,
                                  :departure_longitude => -122.3, :departure_place_name => "My House",
                                  :destination_latitude => 46.5, :destination_longitude => -122.4,
                                  :destination_place_name => 'My Work', 'departure_pickup_time' => home_pickup + 1.hours,
																	:return_pickup_time => work_pickup }, {'HTTP_AUTHORIZATION' => encode_credentials(@rider.token)}
      expect(response.status).to eq(405)
		end

		it "does create new commuter ride requests when one exists in the future for a differentuser" do
      @rider = FactoryGirl.create(:rider)
      @rider2 = FactoryGirl.create(:generated_rider)
      post "/api/v2/rides/commute", {:type => 'commuter',:departure_latitude => 45.5,
                                  :departure_longitude => -122.3, :departure_place_name => "My House",
                                  :destination_latitude => 46.5, :destination_longitude => -122.4,
                                  :destination_place_name => 'My Work', 'departure_pickup_time' => home_pickup,
																	:return_pickup_time => work_pickup }, {'HTTP_AUTHORIZATION' => encode_credentials(@rider.token)}
      post "/api/v2/rides/commute", {:type => 'commuter',:departure_latitude => 45.5,
                                  :departure_longitude => -122.3, :departure_place_name => "My House",
                                  :destination_latitude => 46.5, :destination_longitude => -122.4,
                                  :destination_place_name => 'My Work', 'departure_pickup_time' => home_pickup + 1.hours,
																	:return_pickup_time => work_pickup }, {'HTTP_AUTHORIZATION' => encode_credentials(@rider2.token)}
      expect(response.status).to eq(200)
		end
	end

	describe "POST /api/v2/rides/commute" do
		it "creates new driver commuter ride requests" do
      @rider = FactoryGirl.create(:rider)
      post "/api/v2/rides/commute", {:type => 'commuter',:departure_latitude => 45.5,
                                  :departure_longitude => -122.3, :departure_place_name => "My House",
                                  :destination_latitude => 46.5, :destination_longitude => -122.4,
                                  :destination_place_name => 'My Work', 'departure_pickup_time' => home_pickup,
																	:return_pickup_time => work_pickup, :driving => true }, {'HTTP_AUTHORIZATION' => encode_credentials(@rider.token)}
      expect(response.status).to eq(200)
		end
	end

  describe "GET /api/v2/rides/tickets" do
    it "receives success" do
      @rider = FactoryGirl.create(:rider)
      get "/api/v2/rides/tickets", {},  {'HTTP_AUTHORIZATION' => encode_credentials(@rider.token)}
      expect(response.status).to eq(200)
    end

    it "gets tickets" do
			@ride = FactoryGirl.create(:ride)
      get "/api/v2/rides/tickets", {},  {'HTTP_AUTHORIZATION' => encode_credentials(@ride.rider.token)}
      expect(response.status).to eq(200)
    end
  end

	describe "POST /api/v2/rides/route" do
		it "updates successfully" do
			@rider = FactoryGirl.create(:rider)
			route = @rider.route
			post "/api/v2/rides/route", { :origin => { :longitude => route.origin.x, :latitude => route.origin.y }, \
														:destination => { :longitude => route.destination.x, :latitude => route.destination.y }, \
														:pickup_zone_center => { :longitude => route.pickup_zone_center.x, :latitude => route.pickup_zone_center.y }, \
														:origin_place_name => route.origin_place_name, \
														:destination_place_name => route.destination_place_name, \
														:pickup_zone_center_place_name => route.pickup_zone_center_place_name, \
														:pickup_time => route.pickup_time, \
														:return_time => route.return_time, \
														:driving => route.driving
													}  , {'HTTP_AUTHORIZATION' => encode_credentials(@rider.token)}	
		end
	end

	describe "POST /api/v2/rides/cancel" do
		it "cancels the ride" do
			fare = FactoryGirl.create(:scheduled_fare)
			ride = fare.rides.where(driving:false).first
			post "/api/v2/rides/cancel", { :ride_id => ride.id }, {'HTTP_AUTHORIZATION' => encode_credentials(ride.rider.token)}
			ride = Ride.find(ride.id)
      expect(ride.state).to eq('aborted')
		end
	end

	describe "DELETE /api/v2/trips" do
		it "cancels the entire trip" do
			trip = FactoryGirl.create(:trip_with_two_rides)
			delete "/api/v2/rides/trips/"+trip.id.to_s, {}, {'HTTP_AUTHORIZATION' => encode_credentials(trip.rides[0].rider.token)}
			trip = Trip.find(trip.id)
      expect(trip.state).to eq('aborted')
		end
	end


end
