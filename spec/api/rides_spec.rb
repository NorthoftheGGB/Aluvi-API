require 'rails_helper'

describe RidesAPI do

	include AuthHelper

	before { RidesAPI.before { env["api.tilt.root"] = "app/views/api" } }

	describe "POST /api/rides/commute" do
		it "creates new commuter ride requests" do
      @rider = FactoryGirl.create(:rider)
      post "/api/rides/commute", {:type => 'commuter',:departure_latitude => 45.5,
                                  :departure_longitude => -122.3, :departure_place_name => "My House",
                                  :destination_latitude => 46.5, :destination_longitude => -122.4,
                                  :destination_place_name => 'My Work', 'departure_pickup_time' => '2014-08-16 7:00:00 -14:00',
																	:return_pickup_time => '2014-08-16 17:00:00 -14:00' }, {'HTTP_AUTHORIZATION' => encode_credentials(@rider.token)}
      expect(response.status).to eq(201)
		end
	end

	describe "POST /api/rides/commute" do
		it "creates new commuter ride requests" do
      @rider = FactoryGirl.create(:rider)
      post "/api/rides/commute", {:type => 'commuter',:departure_latitude => 45.5,
                                  :departure_longitude => -122.3, :departure_place_name => "My House",
                                  :destination_latitude => 46.5, :destination_longitude => -122.4,
                                  :destination_place_name => 'My Work', 'departure_pickup_time' => '2014-08-16 7:00:00 -14:00',
																	:return_pickup_time => '2014-08-16 17:00:00 -14:00', :driving => true }, {'HTTP_AUTHORIZATION' => encode_credentials(@rider.token)}
      expect(response.status).to eq(201)
		end
	end

	describe "POST /api/rides/request" do
    it "processes commuter ride request" do
      @rider = FactoryGirl.create(:rider)
      post "/api/rides/request", {:type => 'commuter',:departure_latitude => 45.5,
                                  :departure_longitude => -122.3, :departure_place_name => "My House",
                                  :destination_latitude => 46.5, :destination_longitude => -122.4,
                                  :destination_place_name => 'My Work'}, {'HTTP_AUTHORIZATION' => encode_credentials(@rider.token)}
      expect(response.status).to eq(201)
    end

    it "processes commuter ride request for demo rider" do
      @demo_rider = FactoryGirl.create(:demo_rider)
      post "/api/rides/request", {:type => 'commuter',:departure_latitude => 45.5,
                                  :departure_longitude => -122.3, :departure_place_name => "My House",
                                  :destination_latitude => 46.5, :destination_longitude => -122.4,
                                  :destination_place_name => 'My Work'},
                                    {'HTTP_AUTHORIZATION' => encode_credentials(@demo_rider.token)}
      expect(response.status).to eq(201)
    end
  end

  describe "POST /api/rides/request/cancel" do
    it "cancels a ride" do
      @ride = FactoryGirl.create(:commuter_ride)
      post "/api/rides/request/cancel", {:ride_id => @ride.id}, {'HTTP_AUTHORIZATION' => encode_credentials(@ride.rider.token)}
      expect(response.status).to eq(200)
    end
  end

  describe "GET /api/rides/fares" do
    it "gets fares" do
      @driver = FactoryGirl.create(:driver)
      @fare = FactoryGirl.create(:fare)
      get "/api/rides/fares", {},  {'HTTP_AUTHORIZATION' => encode_credentials(@driver.token)}
      expect(response.status).to eq(200)

    end
  end

  describe "GET /api/rides/tickets" do
    it "receives success" do
      @rider = FactoryGirl.create(:rider)
      get "/api/rides/tickets", {},  {'HTTP_AUTHORIZATION' => encode_credentials(@rider.token)}
      expect(response.status).to eq(200)
    end

    it "gets tickets" do
			@ride = FactoryGirl.create(:ride)
      get "/api/rides/tickets", {},  {'HTTP_AUTHORIZATION' => encode_credentials(@ride.rider.token)}
      expect(response.status).to eq(200)

    end
  end

  describe "GET /api/rides/payments" do
    it "gets payments" do
      @rider = FactoryGirl.create(:rider)
      get "/api/rides/payments", {},  {'HTTP_AUTHORIZATION' => encode_credentials(@rider.token)}
      expect(response.status).to eq(200)

    end
  end

  describe "GET /api/rides/earnings" do
    it "gets earnings" do
      @driver = FactoryGirl.create(:approved_driver)
      get "/api/rides/earnings", {},  {'HTTP_AUTHORIZATION' => encode_credentials(@driver.token)}
      expect(response.status).to eq(200)

    end
  end

  describe "GET /api/rides/fare/:id" do
    it "gets fare details" do
      @fare = FactoryGirl.create(:scheduled_fare)
      @rider = @fare.riders.first
      Rails.logger.debug @rider.token


      get "/api/rides/fares/" + @fare.id.to_s, {},  {'HTTP_AUTHORIZATION' => encode_credentials(@rider.token)}
      expect(response.status).to eq(200)

    end
  end

	describe "DELETE /api/rides/trips/:id" do
		it "cancels an entire trip" do
			@trip = FactoryGirl.create(:trip)
			delete "/api/rides/trips/" + @trip.id.to_s, {}, {'HTTP_AUTHORIZATION' => encode_credentials(@trip.rides[0].rider.token)}
			expect(response.status).to eq(200)
		end
	end

  describe "GET /api/rides/route" do
    it "gets a rider's route" do
      @driver = FactoryGirl.create(:rider)
      get "/api/rides/route", {},  {'HTTP_AUTHORIZATION' => encode_credentials(@driver.token)}
      expect(response.status).to eq(200)

    end
  end


end
