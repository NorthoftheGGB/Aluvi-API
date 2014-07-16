class DriversAPI < Grape::API
	version 'v1', using: :header, vendor: 'voco'
	format :json
	formatter :json, Grape::Formatter::Jbuilder

	resources :drivers do

		desc "Get Specific Driver"
		get  ':id' do
			authenticate!
			driver = User.find(params[:id])
			unless driver.nil?
				driver
			else
				not_found
			end
		end

		desc "Register Driver"
		params do 
			requires :drivers_license_number, type: String
			requires :bank_account_name, type: String
			requires :bank_account_number, type: String
			requires :bank_account_routing, type: String
			requires :car_brand, type: String
			requires :car_model, type: String
			requires :car_year, type: String
			requires :car_license_plate, type: String
			optional :referral_code
		end
		post "driver_registration" do
			authenticate!
			begin
				car = Car.new
				car.make = params[:car_brand]
				car.model = params[:car_model]
				car.year = params[:car_year]
				car.license_plate = params[:car_license_plate]
				car.save
				current_user.cars << car
				current_user.driver_role.drivers_license_number = params[:drivers_license_number]
				# need to handle referral codes	

				# directly set up Stripe recipient, don't store banking information on our server
				# TODO: Refactor, this should be moved to it's own class and happen via a delayed job
				recipient = Stripe::Recipient.create(
					:name => current_user.full_name,
					:type => 'individual',
					:bank_account => {
						:country => 'US',
						:routing_number => params[:bank_account_routing],
						:account_number => params[:bank_account_number]
					},
					:email => current_user.email
				)
				Rails.logger.debug recipient
				if recipient.nil?
					raise "Stripe recipient not created"
				end
				current_user.stripe_recipient_id = recipient.id

				current_user.save
				current_user.driver_role.register!
				ok
			rescue
				Rails.logger.debug $!
				raise $!
			end
			 
		end

		desc "Clock On"
		params do 
		end
		post "clock_on" do
			authenticate!
			current_user.driver_role.clock_on!
			ok
		end

		desc "Clock Off"
		params do 
		end
		post "clock_off" do
			authenticate!
			current_user.driver_role.clock_off!
			ok
		end

		desc "Load Ride Details for Driver"
		get "rides/:id", jbuilder: 'ride' do
			authenticate!
			@ride = Ride.find(params[:id])
			unless @ride.nil?
				@ride		
			else
				not_found
			end
		end

	end
end

