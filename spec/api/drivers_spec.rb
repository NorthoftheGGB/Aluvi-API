require 'rails_helper'

describe DriversAPI do

	include AuthHelper

	before(:all) do
		user = User.user_with_phone('123 123 1232')
		user.first_name = "Matthew"
		user.last_name = "Rie"
		user.email = 'whatever@myhouse.com'
		user.password = 'whalesandthings'
		user.token = "test_access1"
		user.interested_in_driving
		user.save

		user.driver_role.state = 'approved'
		user.driver_role.save
	end

	describe "POST /api/drivers/driver_registration" do
		it "returns sucesss" do
			credentials = ActionController::HttpAuthentication::Token.encode_credentials("test_access1")
			Rails.logger.info credentials
			post "/api/drivers/driver_registration",
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
			Rails.logger.info response.status.to_s + ':' + response.body
			expect(response.status).to eq(201)
		end
	end
end
