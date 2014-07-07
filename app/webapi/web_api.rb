require 'grape-swagger'

class WebAPI < Grape::API
	version 'v1', using: :header, vendor: 'voco'
	format :json
	formatter :json, Grape::Formatter::Jbuilder
	content_type :json, "application/json"

	include voco_api_helper

	resources :entities do

		desc "Log the user in"
		params do
			requires :phone, type: String
			requires :password, type: String
		end
		post "authenicate" do

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
			current_user.token = "";
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
		get "rides", jbuilder: 'web_rides' do
			authenticate!
			if( params[:role] == :rider )
				@rides = current_user.rides
			else if ( params[:role] == :driver )
				@rides = current_user.fares
			else if ( params[:role] == :admin )

				if params['rider_id']
					@rides.includes(:riders).where( :riders => { rider_id: params['rider_id'] } )
				end

				if params['driver_id']
					@rides.includes(:driver).where( :drivers => { driver_id: params['driver_id'] } )
				end

			else
				Raise "Invalid Role"
			end
			if params['begin_date']
				@rides.where( "started >", params['begin_date']
			else 
				@rides.where( "started >", 3.months.ago)
			end

			if params['end_date']
				@rides.where( "started <", params['end_date']
			else 
				@rides.where( "started >", DateTime.now)
			end
	
			if params['ride_id']
				@rides.where( :id => params['ride_id']
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
		get "users", jbuilder: 'web_users' do
			authenticate!
			if role == :admin
				unless params[:user_id].nil?
					user = User.find(params[:user_id])
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
