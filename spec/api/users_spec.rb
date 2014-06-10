require 'rails_helper'

describe UsersAPI do

	before(:all) do
		user = User.user_with_email('forgot@forgot.com')
		user.phone = '123123'
		user.password = user.hash_password('whalesandthings')
		user.save
	end

	describe "POST /api/users" do
		it "returns success" do
			post "/api/users", :email => 'test@test.com', :phone => '123123', :password => 'asdfasdfs', :name => "Jeff Shotz"
			expect(response.status).to eq(201)
		end

		it "returns failure" do
			post "/api/users", :email => 'test@test.com'
			expect(response.status).to eq(400)
		end

	end

	describe "POST /api/users/forgot_password" do
		it "returns success" do
			post "/api/users/forgot_password", :email => 'forgot@forgot.com', :phone => '123123'
			expect(response.status).to eq(201)
		end
	end

	describe "POST /api/users/login" do
		it "returns success" do
			post "/api/users/login", :email => 'forgot@forgot.com', :password => 'whalesandthings'
			expect(response.status).to eq(201)
		end

		it "fails" do
			post "/api/users/login", :email => 'forgot@forgot.com', :password => 'snailsandthings'
			expect(response.status).to eq(404)
		end
	end

	describe "POST /api/users/driver_interested" do
		it "returns success" do
			post "/api/users/driver_interested", :email => 'test@test.com', :phone => '123123', :region => 'asdfasdfs', :name => "Jeff Shotz"
			expect(response.status).to eq(201)
		end
	end
end
