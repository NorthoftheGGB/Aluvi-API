require 'rails_helper'

describe UsersAPI do

	include AuthHelper

	describe "POST /api/users" do
		it "returns success" do
			post "/api/users", :first_name => 'Matty', :last_name => 'Tetson', :email => 'test@test.com', :phone => '1231231232', :password => 'asdfasdfs'
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
      @rider = FactoryGirl.create(:rider)
			post "/api/users/forgot_password", :email => @rider.email, :phone => @rider.phone
			expect(response.status).to eq(201)
			Rails.logger.info response.status.to_s + ':' + response.body
		end
	end

	describe "POST /api/users/login" do
		it "returns success" do
      @rider = FactoryGirl.create(:rider)
      @rider.password = 'whalesandthings'
      @rider.save
			post "/api/users/login", :phone => @rider.phone, :password => 'whalesandthings'
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
