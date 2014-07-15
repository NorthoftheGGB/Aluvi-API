require 'grape-swagger'

class WebAPI < Grape::API
	version 'v1', using: :header, vendor: 'voco' #, cascade: false
	format :json
	formatter :json, Grape::Formatter::Jbuilder
	content_type :json, "application/json"

	helpers do
		include VocoApiHelper
	
		def current_user
			auth = token_and_options(headers['Authorization'])
			@current_user ||= User.authorize_web!(auth[0])
		end

	end

	resources :web do

		desc "Log the user in"
		params do
			requires :phone, type: String
			requires :password, type: String
		end
		post "authenticate" do
			begin
				user = User.where(:phone => params['phone']).first
				if user.nil?
					raise "User not found"
				end
				if user.password != user.hash_password(params['password'])
					raise "Wrong password"
				end
				token = user.generate_web_token!
				response = Hash.new
				response["webtoken"] = token
				roles = Array.new
				unless current_user.rider_role.nil?
					roles << "rider"
				end
				unless current_user.driver_role.nil?
					roles << "driver"
				end
				response["roles"] = roles

				response
			rescue
				puts $!.message
				error! 'Invalid Login', 404, 'X-Error-Detail' => 'Invalid Login'
			end
		end

		desc "Log the user out"
		post 'logout' do
			current_user.web_token = "";
			current_user.save
		end


		desc "Get trip information"
		params do
			optional :begin_date, type: DateTime
			optional :end_date, type: DateTime
			optional :ride_id, type: Integer
			optional :rider_id, type: Integer
			optional :driver_id, type: Integer
			optional :role, type: Symbol, values: [:rider, :driver, :admin], default: :rider
		end
		get "trips", jbuilder: 'web_rides' do
			authenticate!
			if( params[:role] == :rider )
				@rides = current_user.rides
			elsif ( params[:role] == :driver )
				@rides = current_user.fares
			elsif ( params[:role] == :admin )

				@rides = Ride.order('rides.id')
				if params['rider_id']
					@rides = Ride.includes(:riders).where( :users => { id: params['rider_id'] } )
				end

				if params['driver_id']
					@rides = Ride.includes(:driver).where( :users => { id: params['driver_id'] } )
				end

			else
				raise "Invalid Role"
			end

			if params['begin_date']
				@rides.where( "started >", params['begin_date'])
			else 
				@rides.where( "started >", 3.months.ago)
			end

			if params['end_date']
				@rides.where( "started <", params['end_date'])
			else 
				@rides.where( "started >", DateTime.now)
			end

			if params['ride_id']
				@rides.where( :id => params['ride_id'])
			end

		end

		desc "Users"
		params do
			optional :role, type: Symbol, values: [:rider, :driver, :admin], default: :rider
			optional :user_id, type: Integer
			optional :first_name, type: String
			optional :last_name, type: String
			optional :phone_number, type: String
		end
		# put/post of user documents
		get "users", jbuilder: 'web_users' do
			authenticate!
			if role == :admin
				if !params[:user_id].nil?
					user = User.find(params[:user_id])
				elsif !params[:phone_number].nil?
					user = User.user_with_phone(params['phone_number'])
				elsif !params[:first_name].nil? || !params[:last_name].nil? || !params[:role].nil? 
					user = User.order('id')
					if !params[:first_name].nil? 
						user.where(:first_name => params[:first_name])
					end
					if !params[:last_name].nil? 
						user.where(:last_name => params[:last_name])
					end
				else
					user = current_user
				end
			else
				user = current_user
			end
			user

		end

	end
end

