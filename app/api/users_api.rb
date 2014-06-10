require 'digest/sha2'
require 'gmail_sender'

class UsersAPI < Grape::API
	version 'v1', using: :header, vendor: 'voco'
	format :json

	resources :users do

		desc "Create new user"
		params do
			requires :name, type: String
			requires :phone, type: String
			requires :password, type: String
			requires :email, type: String
			optional :referral_code, type: String
		end
		post do
			user = User.user_with_email params[:email]
			user.last_name = params[:name]
			user.phone = params[:phone]
			user.password = user.hash_password(params[:password])
			user.referral_code = params[:referral_code]
			user.registered_for_riding
			user.save
			user.rider_role.activate!
			ok
		end

		desc "Forgot password"
		params do
			requires :phone, type: String
			requires :email, type: String
		end
		post "forgot_password" do
			user = User.where(:email => params['email']).where(:phone => params['phone']).first
			unless(user.nil?)
				g = GmailSender.new("matt@vocotransportation.com", "vocoemail1")
				g.send(:to => user.email,
							 :subject => "Password Reset",
							 :content => "Click here to reset your password")
				ok
			else
				error! 'User not found', 404, 'X-Error-Detail' => 'User not found'
			end
		end

		desc "Log the user in"
		params do
			requires :email, type: String
			requires :password, type: String
		end
		post "login" do

			begin
				user = User.where(:email => params['email']).first
				if user.nil?
					raise "User not found"
				end
				if user.password != user.hash_password(params['password'])
					raise "Wrong password"
				end
				user.token = SecureRandom.hex(64)
				user.save
				response = Hash.new
				response["token"] = user.token
				response
			rescue
				puts $!.message
				error! 'Invalid Login', 404, 'X-Error-Detail' => 'Invalid Login'
			end
		end

		desc "Driver interested"
		params do
			requires :name, type: String
			requires :phone, type: String
			requires :region, type: String
			requires :email, type: String
			optional :driver_referral_code, type: String	
		end
		post "driver_interested" do
			user = User.user_with_email params[:email]
			user.last_name = params[:name]
			user.phone = params[:phone]
			user.driver_request_region = params[:region]
			user.driver_referral_code = params[:driver_referral_code]
			user.interested_in_driving
			user.save
			ok
		end

	end

end

