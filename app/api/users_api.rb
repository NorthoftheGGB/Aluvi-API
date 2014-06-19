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
			user = User.user_with_phone params[:phone]
			unless(user.rider_role.nil? || user.rider_role.state == 'registered')
				error! 'Already Registered', 403, 'X-Error-Detail' => 'Already Registered for Riding'	
				return
			end
			user.last_name = params[:name]
			user.email = params[:email]
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
			requires :phone, type: String
			requires :password, type: String
		end
		post "login" do

			begin
				user = User.where(:phone => params['phone']).first
				if user.nil?
					raise "User not found"
				end
				if user.password != user.hash_password(params['password'])
					raise "Wrong password"
				end
				token = user.generate_token!
				response = Hash.new
				response["token"] = token
				response["rider_state"] = user.rider_state
				response["driver_state"] = user.driver_state
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
			requires :driver_request_region, type: String
			requires :email, type: String
			optional :driver_referral_code, type: String	
		end
		post "driver_interested" do

			state = ''
			if current_user
				current_user.driver_request_region = params[:driver_request_region]
				unless params[:driver_referral_code].nil?
					current_user.driver_referral_code = params[:driver_referral_code]
				end
				current_user.interested_in_driving
				current_user.save
				driver_state = current_user.driver_state
			else
				user = User.user_with_phone params[:phone]
				user.last_name = params[:name]
				user.email = params[:email]
				user.driver_request_region = params[:driver_request_region]
				user.driver_referral_code = params[:driver_referral_code]
				user.interested_in_driving
				user.save
				driver_state = user.driver_state
			end

			response = Hash.new
			response["driver_state"] = driver_state
			response
		end

		desc "Get user states"
		get "state" do
			authenticate!
			response = Hash.new
			response["rider_state"] = current_user.rider_state
			response["driver_state"] = current_user.driver_state
			response
		end

	end

	def driver_interested params
		end

end

