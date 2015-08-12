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
			expect(response.status).to eq(200)
			Rails.logger.info response.status.to_s + ':' + response.body
		end
	end

	describe "POST /api/users/login" do
		it "returns success" do
      @rider = FactoryGirl.create(:rider)
      @rider.password = 'whalesandthings'
      @rider.save
			post "/api/users/login", :email => @rider.email, :password => 'whalesandthings'
			Rails.logger.info response.status.to_s + ':' + response.body
			expect(response.status).to eq(200)
		end

		it "returns forbidden" do
      @rider = FactoryGirl.create(:rider)
      post "/api/users/login", :email => @rider.email, :password => 'snailsandthings'
			Rails.logger.info response.status.to_s + ':' + response.body
			expect(response.status).to eq(401)
		end

		it "returns not found" do
      post "/api/users/login", :email => "asdflkjasldfjkaslxdfjaxlsdkjf@you.com", :password => 'snailsandthings'
			Rails.logger.info response.status.to_s + ':' + response.body
			expect(response.status).to eq(404)
		end
	end

	describe "POST /api/users/driver_interested" do
		it "returns success for new driver" do
			post "/api/users/driver_interested", :email => 'test@test.com', :phone => '1231234444', :driver_request_region => 'asdfasdfs', :name => "Jeff Shotz"
			Rails.logger.info response.status.to_s + ':' + response.body
			expect(response.status).to eq(200)
		end

		it "returns success for existing driver" do
      @rider = FactoryGirl.create(:rider)
			post "/api/users/driver_interested", {:email => 'test@test.com', :phone => '1231235555', :driver_request_region => 'asdfasdfs', :name => "Jeff Shotz" }, {'HTTP_AUTHORIZATION' => encode_credentials(@rider.token)}
			Rails.logger.info response.status.to_s + ':' + response.body
			expect(response.status).to eq(200)
		end
	end

	describe "POST /api/users/support" do
		it "returns success" do
      @rider = FactoryGirl.create(:rider)
			post "/api/users/support", { :message => 'support message' },  {'HTTP_AUTHORIZATION' => encode_credentials(@rider.token)}
			expect(response.status).to eq(200)
		end
	end


	describe "POST /api/users/profile" do
		it "returns success" do
			@rider = FactoryGirl.create(:rider)
			post "/api/users/profile", { :first_name => @rider.first_name, :last_name => @rider.last_name, :email => @rider.email, :phone => @rider.phone, :default_card_token => 'asdfasdfasdfasdf', :default_recipient_debit_card_token => 'apsoidfjapwoeijfapwoiefja' },  {'HTTP_AUTHORIZATION' => encode_credentials(@rider.token)}
			expect(response.status).to eq(200)
		end
	end

end
