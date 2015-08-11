require 'rails_helper'

describe RidesAPIV2 do

	include AuthHelper

	before { RidesAPIV2.before { env["api.tilt.root"] = "app/views/api" } }

	describe "POST /api/v2/rides/commute" do
		it "creates new commuter ride requests" do
      @rider = FactoryGirl.create(:rider)
      post "/api/v2/rides/commute", {:type => 'commuter',:departure_latitude => 45.5,
                                  :departure_longitude => -122.3, :departure_place_name => "My House",
                                  :destination_latitude => 46.5, :destination_longitude => -122.4,
                                  :destination_place_name => 'My Work', 'departure_pickup_time' => '2014-08-16 7:00:00 -14:00',
																	:return_pickup_time => '2014-08-16 17:00:00 -14:00' }, {'HTTP_AUTHORIZATION' => encode_credentials(@rider.token)}
      expect(response.status).to eq(200)
		end

		it "does not create new commuter ride requests when one exists in the future" do
      @rider = FactoryGirl.create(:rider)
      post "/api/v2/rides/commute", {:type => 'commuter',:departure_latitude => 45.5,
                                  :departure_longitude => -122.3, :departure_place_name => "My House",
                                  :destination_latitude => 46.5, :destination_longitude => -122.4,
                                  :destination_place_name => 'My Work', 'departure_pickup_time' => '2014-08-16 7:00:00 -14:00',
																	:return_pickup_time => '2014-08-16 17:00:00 -14:00' }, {'HTTP_AUTHORIZATION' => encode_credentials(@rider.token)}
      post "/api/v2/rides/commute", {:type => 'commuter',:departure_latitude => 45.5,
                                  :departure_longitude => -122.3, :departure_place_name => "My House",
                                  :destination_latitude => 46.5, :destination_longitude => -122.4,
                                  :destination_place_name => 'My Work', 'departure_pickup_time' => '2014-08-16 9:00:00 -14:00',
																	:return_pickup_time => '2014-08-16 17:00:00 -14:00' }, {'HTTP_AUTHORIZATION' => encode_credentials(@rider.token)}
      expect(response.status).to eq(405)
		end

		it "does create new commuter ride requests when one exists in the future for a differentuser" do
      @rider = FactoryGirl.create(:rider)
      @rider2 = FactoryGirl.create(:generated_rider)
      post "/api/v2/rides/commute", {:type => 'commuter',:departure_latitude => 45.5,
                                  :departure_longitude => -122.3, :departure_place_name => "My House",
                                  :destination_latitude => 46.5, :destination_longitude => -122.4,
                                  :destination_place_name => 'My Work', 'departure_pickup_time' => '2014-08-16 7:00:00 -14:00',
																	:return_pickup_time => '2014-08-16 17:00:00 -14:00' }, {'HTTP_AUTHORIZATION' => encode_credentials(@rider.token)}
      post "/api/v2/rides/commute", {:type => 'commuter',:departure_latitude => 45.5,
                                  :departure_longitude => -122.3, :departure_place_name => "My House",
                                  :destination_latitude => 46.5, :destination_longitude => -122.4,
                                  :destination_place_name => 'My Work', 'departure_pickup_time' => '2014-08-16 9:00:00 -14:00',
																	:return_pickup_time => '2014-08-16 17:00:00 -14:00' }, {'HTTP_AUTHORIZATION' => encode_credentials(@rider2.token)}
      expect(response.status).to eq(200)
		end
	end

	describe "POST /api/v2/rides/commute" do
		it "creates new driver commuter ride requests" do
      @rider = FactoryGirl.create(:rider)
      post "/api/v2/rides/commute", {:type => 'commuter',:departure_latitude => 45.5,
                                  :departure_longitude => -122.3, :departure_place_name => "My House",
                                  :destination_latitude => 46.5, :destination_longitude => -122.4,
                                  :destination_place_name => 'My Work', 'departure_pickup_time' => '2014-08-16 7:00:00 -14:00',
																	:return_pickup_time => '2014-08-16 17:00:00 -14:00', :driving => true }, {'HTTP_AUTHORIZATION' => encode_credentials(@rider.token)}
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


end
