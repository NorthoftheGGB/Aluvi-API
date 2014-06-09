require 'rails_helper'

describe UsersAPI do
	describe "POST /api/users" do
		it "returns success" do
			post "/api/users", :email => 'test@test.com', :phone => 123123, :password => 'asdfasdfs', :name => "Jeff Shotz"
			expect(response.status).to eq(201)
		end

		it "returns failure" do
			post "/api/users", :email => 'test@test.com'
			expect(response.status).to eq(400)
		end
	end
end
