require 'rails_helper'

describe RidesAPI do

	include AuthHelper

	before { RidesAPI.before { env["api.tilt.root"] = "app/views/api" } }

	describe "POST /api/v2/rides/commute" do
		it "creates new commuter ride requests" do
      @rider = FactoryGirl.create(:rider)
      post "/api/v2/rides/commute", {:type => 'commuter',:departure_latitude => 45.5,
                                  :departure_longitude => -122.3, :departure_place_name => "My House",
                                  :destination_latitude => 46.5, :destination_longitude => -122.4,
                                  :destination_place_name => 'My Work', 'departure_pickup_time' => '2014-08-16 7:00:00 -14:00',
																	:return_pickup_time => '2014-08-16 17:00:00 -14:00' }, {'HTTP_AUTHORIZATION' => encode_credentials(@rider.token)}
      expect(response.status).to eq(201)
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
      expect(response.status).to eq(201)
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


end
