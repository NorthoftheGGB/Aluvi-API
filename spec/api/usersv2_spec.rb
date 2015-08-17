require 'rails_helper'

describe UsersAPI do

	include AuthHelper

#	let(:stripe_helper) { StripeMock.create_test_helper }
#	before { StripeMock.start }
#	after { StripeMock.stop }

	describe "POST /api/v2/users" do
		it "returns success" do
			post "/api/v2/users", :first_name => 'Matty', :last_name => 'Tetson', :email => 'test@test.com', :phone => '1231231232', :password => 'asdfasdfs'
			Rails.logger.info response.status.to_s + ':' + response.body
			expect(response.status).to eq(200)
    end

		it "returns failure" do
			post "/api/v2/users", :email => 'test@test.com'
			Rails.logger.info response.status.to_s + ':' + response.body
			expect(response.status).to eq(400)
		end

	end

	describe "POST /api/v2/users/forgot_password" do
		it "returns success" do
      @rider = FactoryGirl.create(:rider)
			post "/api/v2/users/forgot_password", :email => @rider.email, :phone => @rider.phone
			expect(response.status).to eq(200)
			Rails.logger.info response.status.to_s + ':' + response.body
		end
	end

	describe "POST /api/v2/users/login" do
		it "returns success" do
      @rider = FactoryGirl.create(:rider)
      @rider.password = 'whalesandthings'
      @rider.save
			post "/api/v2/users/login", :email => @rider.email, :password => 'whalesandthings'
			Rails.logger.info response.status.to_s + ':' + response.body
			expect(response.status).to eq(200)
		end

		it "returns forbidden" do
      @rider = FactoryGirl.create(:rider)
      post "/api/v2/users/login", :email => @rider.email, :password => 'snailsandthings'
			Rails.logger.info response.status.to_s + ':' + response.body
			expect(response.status).to eq(401)
		end

		it "returns not found" do
      post "/api/v2/users/login", :email => "asdflkjasldfjkaslxdfjaxlsdkjf@you.com", :password => 'snailsandthings'
			Rails.logger.info response.status.to_s + ':' + response.body
			expect(response.status).to eq(404)
		end
	end

	describe "POST /api/v2/users/driver_interested" do
		it "returns success for new driver" do
			post "/api/v2/users/driver_interested", :email => 'test@test.com', :phone => '1231234444', :driver_request_region => 'asdfasdfs', :name => "Jeff Shotz"
			Rails.logger.info response.status.to_s + ':' + response.body
			expect(response.status).to eq(200)
		end

		it "returns success for existing driver" do
      @rider = FactoryGirl.create(:rider)
			post "/api/v2/users/driver_interested", {:email => 'test@test.com', :phone => '1231235555', :driver_request_region => 'asdfasdfs', :name => "Jeff Shotz" }, {'HTTP_AUTHORIZATION' => encode_credentials(@rider.token)}
			Rails.logger.info response.status.to_s + ':' + response.body
			expect(response.status).to eq(200)
		end
	end

	describe "POST /api/v2/users/support" do
		it "returns success" do
      @rider = FactoryGirl.create(:rider)
			post "/api/v2/users/support", { :message => 'support message' },  {'HTTP_AUTHORIZATION' => encode_credentials(@rider.token)}
			expect(response.status).to eq(200)
		end
	end


	describe "POST /api/v2/users/profile" do
		it "returns success without cards" do
			@rider = FactoryGirl.create(:rider)
			post "/api/v2/users/profile", { :first_name => 'a' + @rider.first_name, :last_name => 'a' + @rider.last_name, :email => 'a' + @rider.email, :phone => '1231231234' },  {'HTTP_AUTHORIZATION' => encode_credentials(@rider.token)}
			expect(response.status).to eq(200)
		end
		it "returns success with no changes" do
			@rider = FactoryGirl.create(:rider)
			post "/api/v2/users/profile", { :first_name => @rider.first_name, :last_name => @rider.last_name, :email => @rider.email, :phone => @rider.phone },  {'HTTP_AUTHORIZATION' => encode_credentials(@rider.token)}
			expect(response.status).to eq(200)
		end
		it "returns success with changes name, same email" do
			@rider = FactoryGirl.create(:rider)
			post "/api/v2/users/profile", { :first_name => 'a' + @rider.first_name, :last_name => 'a' + @rider.last_name, :email => @rider.email, :phone => @rider.phone },  {'HTTP_AUTHORIZATION' => encode_credentials(@rider.token)}
			expect(response.status).to eq(200)
		end

		it "returns success with payment cards" do
			@rider = FactoryGirl.create(:rider)
			token = Stripe::Token.create(
				:card => {
					:number => "4242424242424242",
					:exp_month => 8,
					:exp_year => 2016,
					:cvc => "314"
				},
			)
			Rails.logger.debug token
			Rails.logger.debug token["id"]
			Rails.logger.debug token.id
			post "/api/v2/users/profile", { :first_name => @rider.first_name, :last_name => @rider.last_name, :email => @rider.email, :phone => '1231231234', :default_card_token => token["id"] },  {'HTTP_AUTHORIZATION' => encode_credentials(@rider.token)}
			expect(response.status).to eq(200)
		end

		it "returns success with cards" do
			@rider = FactoryGirl.create(:generated_driver)
			token = Stripe::Token.create(
				:card => {
					:number => "4000056655665556",
					:exp_month => 8,
					:exp_year => 2016,
					:cvc => "314"
				},
			)
			Rails.logger.debug token
			Rails.logger.debug token["id"]
			Rails.logger.debug token.id
			post "/api/v2/users/profile", { :first_name => @rider.first_name, :last_name => @rider.last_name, :email => @rider.email, :phone => '1231231234', :default_recipient_debit_card_token => token["id"] },  {'HTTP_AUTHORIZATION' => encode_credentials(@rider.token)}
			expect(response.status).to eq(200)
		end
	end

end
