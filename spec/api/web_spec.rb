require 'rails_helper'

describe WebAPI do

	include AuthHelper

	before { WebAPI.before { env["api.tilt.root"] = "app/views/api" } }

	describe "POST /api/web/authenticate" do
		it "allows authentication" do
      @rider = FactoryGirl.create(:rider)
      @rider.password = 'whalesandthings'
      @rider.save
			post "/api/web/authenticate", :phone => @rider.phone, :password => 'whalesandthings'
			expect(response.status).to eq(200)
		end
	end

	describe "GET /api/web/trips" do
		it "returns a list of rides by default" do
      @rider = FactoryGirl.create(:rider)
      get "/api/web/trips", {},  {'HTTP_AUTHORIZATION' => encode_credentials(@rider.webtoken)}
			expect(response.status).to eq(200)
		end

		it "returns a list of rides when role is rider" do
      @rider = FactoryGirl.create(:rider)
      get "/api/web/trips", {:role => 'rider'}, {'HTTP_AUTHORIZATION' => encode_credentials(@rider.webtoken)}
			expect(response.status).to eq(200)
		end

		it "returns a list of rides when role is driver" do
      @driver = FactoryGirl.create(:driver)
			get "/api/web/trips", {:role => 'driver'},{'HTTP_AUTHORIZATION' => encode_credentials(@driver.webtoken)}
			expect(response.status).to eq(200)
		end

		it "returns a list of rides when role is admin" do
      @driver = FactoryGirl.create(:driver)
      get "/api/web/trips", {:role => 'admin'}, {'HTTP_AUTHORIZATION' => encode_credentials(@driver.webtoken)}
      expect(response.status).to eq(200)
		end

		it "returns a list of rides when role is rider, filtered by date" do
      @rider = FactoryGirl.create(:rider)
      get "/api/web/trips", {:role => 'rider', :begin_date => '2014-05-05', :end_date => '2014-07-07'}, {'HTTP_AUTHORIZATION' => encode_credentials(@rider.webtoken) }
      expect(response.status).to eq(200)
		end

		it "returns a list of rides when role is admin, rider_id provided" do
      @driver = FactoryGirl.create(:driver)
      get "/api/web/trips", {:role => 'admin', :rider_id => 1 }, {'HTTP_AUTHORIZATION' => encode_credentials(@driver.webtoken) }
      expect(response.status).to eq(200)
		end

		it "returns a list of rides when role is admin, driver_id provided" do
      @driver = FactoryGirl.create(:driver)
      get "/api/web/trips", {:role => 'admin', :driver_id => 1 },{'HTTP_AUTHORIZATION' => encode_credentials(@driver.webtoken) }
      expect(response.status).to eq(200)
		end

		it "returns a list of rides when role is admin, fare_id provided" do
      @driver = FactoryGirl.create(:driver)
      get "/api/web/trips", {:role => 'admin', :fare_id => 110 },{'HTTP_AUTHORIZATION' => encode_credentials(@driver.webtoken) }
      expect(response.status).to eq(200)
		end

	end


end
