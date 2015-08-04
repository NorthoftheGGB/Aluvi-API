require 'rails_helper'

describe DriversAPI do

	include AuthHelper

	describe "POST /api/drivers/driver_registration" do
		it "returns sucesss" do
      @driver = FactoryGirl.create(:driver)
			post "/api/drivers/driver_registration",
				{ 
				:drivers_license_number => "KLSJLSKDF", 
				:car_brand => "Toyota", 
				:car_model => "Pickup Truck", 
				:car_year => "1985", 
				:car_license_plate => "SDF 3423" }, 
				{'HTTP_AUTHORIZATION' => encode_credentials(@driver.token)}
			Rails.logger.info response.status.to_s + ':' + response.body
			expect(response.status).to eq(201)
		end
	end
end
