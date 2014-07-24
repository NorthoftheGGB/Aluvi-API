require 'rails_helper'

describe UsersAPI do

	include AuthHelper

	before(:all) do
		user = User.user_with_phone('123 123 1232')
		user.first_name = "Matthew"
		user.last_name = "Rie"
		user.email = 'whatever@myhouse.com'
		user.password = 'whalesandthings'
		Rails.logger.info 'setting pass'
		Rails.logger.info user.hash_password('whalesandthings')
		user.token = "test_access1"
		user.interested_in_driving
		user.save
		# http_login not working
	end

	describe "POST /api/users" do
		it "returns success" do
			post "/api/users", :first_name => 'Matty', :last_name => 'Tetson', :email => 'test@test.com', :phone => '123 123 1232', :password => 'asdfasdfs', :name => "Jeff Shotz"
			Rails.logger.info response.status.to_s + ':' + response.body
			expect(response.status).to eq(201)
		end
		it "returns failure" do
			post "/api/users", :email => 'test@test.com'
			Rails.logger.info response.status.to_s + ':' + response.body
			expect(response.status).to eq(400)
		end

	end

	describe "POST /api/users/forgot_password" do
		it "returns success" do
			post "/api/users/forgot_password", :email => 'whatever@myhouse.com', :phone => '123 123 1232'
			expect(response.status).to eq(201)
			Rails.logger.info response.status.to_s + ':' + response.body
		end
	end

	describe "POST /api/users/login" do
		it "returns success" do
			post "/api/users/login", :phone => '123 123 1232', :password => 'whalesandthings'
			Rails.logger.info response.status.to_s + ':' + response.body
			expect(response.status).to eq(201)
		end

		it "fails" do
			post "/api/users/login", :phone => '123 123 1232', :password => 'snailsandthings'
			Rails.logger.info response.status.to_s + ':' + response.body
			expect(response.status).to eq(404)
		end
	end

	describe "POST /api/users/driver_interested" do
		it "returns success" do
			post "/api/users/driver_interested", :email => 'test@test.com', :phone => '123 123 1236', :driver_request_region => 'asdfasdfs', :name => "Jeff Shotz"
			Rails.logger.info response.status.to_s + ':' + response.body
			expect(response.status).to eq(201)
		end
	end

end
