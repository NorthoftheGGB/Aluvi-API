class DriversAPI < Grape::API
	version 'v1', using: :header, vendor: 'voco'
	format :json
	formatter :json, Grape::Formatter::Jbuilder

	rescue_from AASM::InvalidTransition do |e|
		client_error $!
	end


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
			requires :car_brand, type: String
			requires :car_model, type: String
			requires :car_year, type: String #, regexp: /^[0-9][0-9][0-9][0-9]$/
			requires :car_license_plate, type: String
			optional :referral_code
		end
		post "driver_registration" do
			authenticate!
			begin
				driver = Driver.unscoped.find(current_user.id)
					ActiveRecord::Base.transaction do
					driver.interested
					driver.approve

					car = Car.new
					car.make = params[:car_brand]
					car.model = params[:car_model]
					car.year = params[:car_year]
					car.license_plate = params[:car_license_plate]
					car.save
					driver.cars << car
					driver.car = car	
					driver.drivers_license_number = params[:drivers_license_number]
					# need to handle referral codes	

					driver.save
					driver.register
					driver.activate
					driver.save
					status 200
					ok
				end

			rescue Stripe::InvalidRequestError
				client_error $!.message

			rescue AASM::InvalidTransition
				if driver.active?
					ok
				else
					client_error $!.message
				end

			rescue
				Rails.logger.debug "driver registration failure"
				Rails.logger.error $!.message
        Rails.logger.error $!.backtrace.join("\n")
				client_error $!
			end
			 
		end

		desc "Clock On"
		params do 
		end
		post "clock_on" do
			authenticate!
			unless current_driver.state == 'on_duty'
				current_driver.clock_on!
			end
			ok
		end

		desc "Clock Off"
		params do 
		end
		post "clock_off" do
			authenticate!
			if current_driver.state == 'on_duty'
				current_driver.clock_off!
			end
			ok
		end

		desc "Load Fare Details for Driver"
		get "fares/:id", jbuilder: 'fare' do
			authenticate!
			@fare = Fare.find(params[:id])
			unless @fare.nil?
				@fare
			else
				not_found
			end
		end

	end
end

