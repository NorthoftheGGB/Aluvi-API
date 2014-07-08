require 'rails_helper'

describe WebAPI do

	include AuthHelper

	before(:all) do
		user = User.user_with_phone('123 123 1232')
		user.first_name = "Matthew"
		user.last_name = "Rie"
		user.email = 'whatever@myhouse.com'
		user.password = user.hash_password('whalesandthings')
		user.webtoken = "test_access1"
		user.interested_in_driving
		rider_role = RiderRole.new
		user.rider_role = rider_role
		driver_role = DriverRole.new
		user.driver_role = driver_role
		user.save
	end

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
