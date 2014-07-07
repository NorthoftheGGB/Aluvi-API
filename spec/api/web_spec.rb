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

	describe "GET /api/web/trips" do

	end


end
