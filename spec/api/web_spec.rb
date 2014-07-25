require 'rails_helper'

describe WebAPI do

	include AuthHelper

	before { WebAPI.before { env["api.tilt.root"] = "app/views/api" } }

	describe "POST /api/web/authenticate" do
		it "allows authentication" do
			post "/api/web/authenticate", :phone => '123 123 1232', :password => 'whalesandthings'
			expect(response.status).to eq(200)
		end
	end

	describe "GET /api/web/trips" do
		it "returns a list of rides by default" do
			get "/api/web/trips", {}, {'HTTP_AUTHORIZATION' => credentials}
			expect(response.status).to eq(200)
		end

		it "returns a list of rides when role is rider" do
			get "/api/web/trips", {:role => 'rider'}, {'HTTP_AUTHORIZATION' => credentials}
			expect(response.status).to eq(200)
		end

		it "returns a list of rides when role is driver" do
			get "/api/web/trips", {:role => 'driver'}, {'HTTP_AUTHORIZATION' => credentials}
			expect(response.status).to eq(200)
		end

		it "returns a list of rides when role is admin" do
			get "/api/web/trips", {:role => 'admin'}, {'HTTP_AUTHORIZATION' => credentials}
			expect(response.status).to eq(200)
		end

		it "returns a list of rides when role is rider, filtered by date" do
			get "/api/web/trips", {:role => 'rider', :begin_date => '2014-05-05', :end_date => '2014-07-07'}, {'HTTP_AUTHORIZATION' => credentials}
			expect(response.status).to eq(200)
		end

		it "returns a list of rides when role is admin, rider_id provided" do
			get "/api/web/trips", {:role => 'admin', :rider_id => 1 }, {'HTTP_AUTHORIZATION' => credentials}
			expect(response.status).to eq(200)
		end

		it "returns a list of rides when role is admin, driver_id provided" do
			get "/api/web/trips", {:role => 'admin', :driver_id => 1 }, {'HTTP_AUTHORIZATION' => credentials}
			expect(response.status).to eq(200)
		end

		it "returns a list of rides when role is admin, ride_id provided" do
			get "/api/web/trips", {:role => 'admin', :ride_id => 110 }, {'HTTP_AUTHORIZATION' => credentials}
			expect(response.status).to eq(200)
		end

	end


end
