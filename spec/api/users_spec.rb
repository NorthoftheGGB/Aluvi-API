require 'rails_helper'

describe UsersAPI do

	include AuthHelper

	before(:all) do
		user = User.user_with_phone('123 123 1232')
		user.first_name = "Matthew"
		user.last_name = "Rie"
		user.email = 'whatever@myhouse.com'
		user.password = user.hash_password('whalesandthings')
		user.token = "test_access1"
		user.interested_in_driving
		user.save
		# http_login not working
	end

	describe "POST /api/users" do
		it "returns success" do
			post "/api/users", :email => 'test@test.com', :phone => '123 123 1232', :password => 'asdfasdfs', :name => "Jeff Shotz"
			unless expect(response.status).to eq(201)
				puts response.body
			end
		end
		it "returns failure" do
			post "/api/users", :email => 'test@test.com'
			unless expect(response.status).to eq(400)
				puts response.body
			end
		end

	end

	describe "POST /api/users/forgot_password" do
		it "returns success" do
			post "/api/users/forgot_password", :email => 'whatever@myhouse.com', :phone => '123 123 1232'
			unless expect(response.status).to eq(201)
				puts response.body
			end
		end
	end

	describe "POST /api/users/login" do
		it "returns success" do
			post "/api/users/login", :phone => '123 123 1232', :password => 'whalesandthings'
			unless expect(response.status).to eq(201)
				puts response.body
			end
		end

		it "fails" do
			post "/api/users/login", :phone => '123 123 1232', :password => 'snailsandthings'
			unless expect(response.status).to eq(404)
				puts response.body
			end
		end
	end

	describe "POST /api/users/driver_interested" do
		it "returns success" do
			post "/api/users/driver_interested", :email => 'test@test.com', :phone => '123 123 1236', :driver_request_region => 'asdfasdfs', :name => "Jeff Shotz"
			unless expect(response.status).to eq(201)
				puts response.body
			end
		end
	end

	describe "POST /api/users/driver_registration" do
		credentials = ActionController::HttpAuthentication::Token.encode_credentials("test_access1")
		puts credentials
		it "returns sucesss" do
			post "/api/users/driver_registration",
				{ 
				:drivers_license_number => "KLSJLSKDF", 
				:bank_account_name => "STRIPE TEST BANK", 
				:bank_account_number => "000123456789", 
				:bank_account_routing => "110000000", 
				:car_brand => "Toyota", 
				:car_model => "Pickup Truck", 
				:car_year => "1985", 
				:car_license_plate => "SDF 3423" }, 
				{'HTTP_AUTHORIZATION' => credentials}
				expect(response.status).to eq(201)
		end
	end
end
