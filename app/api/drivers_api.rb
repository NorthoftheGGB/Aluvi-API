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
			requires :bank_account_name, type: String
			requires :bank_account_number, type: String, regexp: /^[0-9]+$/
			requires :bank_account_routing, type: String, regexp: /^[0-9]+$/
			requires :car_brand, type: String
			requires :car_model, type: String
			requires :car_year, type: String #, regexp: /^[0-9][0-9][0-9][0-9]$/
			requires :car_license_plate, type: String
			optional :referral_code
		end
		post "driver_registration" do
			authenticate!
			begin

				ActiveRecord::Base.transaction do
					car = Car.new
					car.make = params[:car_brand]
					car.model = params[:car_model]
					car.year = params[:car_year]
					car.license_plate = params[:car_license_plate]
					car.save
					driver = Driver.find(current_user.id)
					driver.cars << car
					driver.car = car	
					driver.drivers_license_number = params[:drivers_license_number]
					# need to handle referral codes	

					# directly set up Stripe recipient, don't store banking information on our server
					# TODO: Refactor, this should be moved to its own class and happen via a delayed job
					recipient = Stripe::Recipient.create(
						:name => driver.full_name,
						:type => 'individual',
						:bank_account => {
					  	:country => 'US',
					  	:routing_number => params[:bank_account_routing],
					  	:account_number => params[:bank_account_number]
					  },
						:email => driver.email
					)

					if recipient.nil?
						raise "Stripe recipient not created"
					end
					driver.stripe_recipient_id = recipient.id
					driver.bank_account_name = recipient.active_account.bank_name

					driver.save
					driver.register!
					ok
				end

			rescue Stripe::InvalidRequestError
				client_error $!.message

			rescue AASM::InvalidTransition
				client_error $!.message

			rescue
				Rails.logger.debug "driver registration failure"
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

