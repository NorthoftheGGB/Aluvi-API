class RidesAPI< Grape::API
	version 'v1', using: :header, vendor: 'voco'
	format :json
	formatter :json, Grape::Formatter::Jbuilder

	resources :rides do

		desc "Request a ride"
		params do
			requires :type, type: String
			requires :departure_latitude, type: BigDecimal
			requires :departure_longitude, type: BigDecimal
			requires :departure_place_name, type: String
			requires :destination_latitude, type: BigDecimal
			requires :destination_longitude, type: BigDecimal
			requires :destination_place_name, type: String
			optional :pickup_time, type: DateTime
			optional :driving, type: Boolean
			optional :trip_id, type: Integer
		end
		post :request do
			authenticate!
			case params[:type]
        when 'on_demand'
					stale_requests = current_rider.rides.where( state: :requested).all
					stale_requests.each do |request|
						request.cancel!
					end

					ride = OnDemandRide.create!(
																						 RGeo::Geographic.spherical_factory( :srid => 4326 ).point(params[:departure_longitude], params[:departure_latitude]),
																						 params[:departure_place_name],
																						 RGeo::Geographic.spherical_factory( :srid => 4326 ).point(params[:destination_longitude], params[:destination_latitude]),
																						 params[:destination_place_name],
																						 current_rider
																						)
			when 'commuter'
         ride = CommuterRide.create(
																						 RGeo::Geographic.spherical_factory( :srid => 4326 ).point(params[:departure_longitude], params[:departure_latitude]),
																						 params[:departure_place_name],
																						 RGeo::Geographic.spherical_factory( :srid => 4326 ).point(params[:destination_longitude], params[:destination_latitude]),
																						 params[:destination_place_name],
																						 params[:pickup_time],
																						 params[:driving],
                                             current_rider
																						)
				Rails.logger.debug params
				unless params[:trip_id].nil?
					ride.trip_id = params[:trip_id]
				end
				ride.save
			else
				raise "No request type set"
			end

      ride.request!

			if params[:type] == 'commuter'
				if false #current_user.demo
					# demoing subsystem
					demo_rides = Ride.where( :request_type => 'commuter' ).where( :state => 'requested').includes( :rider ).where( :users => { demo: true  } )

					threshold = Rails.application.config.voco_demo_commuter_assembly_trigger_threshold 
					if threshold.nil?
						threshold = 3
					end
					Rails.logger.debug threshold
					if demo_rides.count > threshold
						Rails.logger.debug 'scheduling DEMO commuter ride'
						ActiveRecord::Base.transaction do
							# need to DRY this with the commuter ride requests controller
							fare = Fare.assemble_fare_from_rides demo_rides
              fare.meeting_point_place_name = FaresHelper::reverse_geocode fare.meeting_point
              fare.drop_off_point_place_name = FaresHelper::reverse_geocode  fare.drop_off_point
							drivers = Driver.demo_drivers
							unless drivers.count == 0
								fare.schedule!( nil, DateTime.now, drivers[0], drivers[0].cars.first )
							end
						end
					end
				end
			end

			rval = Hash.new
			rval[:ride_id] = ride.id
			rval[:trip_id] = ride.trip_id
			rval

		end
		
		desc "Cancel a ride request"
		params do
			requires :ride_id, type: Integer
		end
		post "request/cancel" do
			authenticate!
			begin
				ride = Ride.find(params[:ride_id])
				if(ride.rider.id != current_user.id )
					raise ApiExceptions::WrongUserForEntityException
				end
				if !ride.fare.nil? && ride.fare.scheduled?
					#if ride found has yet been delivered to phone, cancel ride instead of request anyway
          ride.fare.rider_cancelled! ride.rider
				else
          ride.cancel!
				end
				ok
			rescue ApiExceptions::WrongUserForEntityException
				Rails.logger.debug $!
				forbidden $!
			rescue AASM::InvalidTransition => e 
				Rails.logger.error e
				forbidden e
      rescue
        Rails.logger.error $!
				Rails.logger.error $!.backtrace.join("\n")
				error! $!.message, 403, 'X-Error-Detail' => $!.message
			end
		end

		desc "Get list of offered rides"
		get 'offers', jbuilder: 'offer' do
			authenticate!
      driver = Driver.find(current_user.id)
			@offers = driver.offers.open_offers
      driver.offers.undelivered_offers.each do |offer|
				offer.offer_delivered!
			end
			@offers
		end

		desc "Get list of fares assigned to driver"
		get 'fares', jbuilder: 'rides' do
			authenticate!
      driver = Driver.find(current_user.id)
      @fares = driver.fares.active

		end

		desc "Get requested and underway ride requests"
		get 'rides', jbuilder: 'rides' do
			authenticate!
      rider = Rider.find(current_user.id)
			@requests = rider.rides.select('*, rides.id as ride_id').joins('JOIN fares ON fares.id = rides.fare_id').where( state: ["requested", "scheduled"])
			@requests.each do |ride|
				# mark as delivered here if we like
			end
			@requests
		end

		desc "Payment Details"
		get :payments do
			authenticate!
			rider = Rider.find(current_user.id)
			rider.payments
		end

		desc "Receipt for Drivers"
		get :earnings do
			authenticate!
			driver = Driver.find(current_user.id)
			driver.earnings
		end

		desc "Get fare details"
		get 'fares/:id' do
			authenticate!
			fare = Fare.find(params[:id])
			unless fare.nil?
				if current_user.involved_in_fare fare
					fare
				else
					forbidden "User not involved in this fare"
				end
			else
				not_found
			end
		end


		desc "Driver accepted fare"
		params do
			requires :fare_id, type: Integer
		end
		post :accepted do
			authenticate!
			fare = Fare.find(params[:fare_id])

			unless(["created", "unscheduled"].include? fare.state)
				if( fare.driver == current_user )
					# ok to return HTTP success
					ok
				else
					error! 'Ride no longer available', 403, 'X-Error-Detail' => 'Ride is no longer available'
					return
				end
			else 
				begin
					driver = Driver.find(current_user.id)
					driver.accepted_fare(fare)
					ok
				rescue AASM::InvalidTransition => e
					if fare.state == "accepted" && fare.driver.id == driver.id
						ok
					else 
						error! 'Ride no longer available', 403, 'X-Error-Detail' => 'Ride is no longer available'
					end
				end
			end

		end

		desc "Driver declined fare"
		params do
			requires :fare_id, type: Integer
		end
		post :declined do
			authenticate!
			fare = Fare.find(params[:fare_id])
			if(fare.state != "created")
				if( fare.driver == current_user )
					error! 'Already assigned to this driver', 404, 'X-Error-Detail' => 'Already assigned to this driver'
				else
					error! 'Ride no longer available', 403, 'X-Error-Detail' => 'Ride is no longer available'
					return
				end
			end

			current_user.declined_fare(fare)
			ok

		end


		desc "Driver cancelled fare"
		params do
			requires :fare_id, type: Integer
		end
		post :driver_cancelled do
			authenticate!
			fare = Fare.find(params[:fare_id])
			begin
				if fare.driver.id != current_user.id
					raise ApiExceptions::RideNotAssignedToThisDriverException
				end
        fare.driver_cancelled!
				ok
			rescue AASM::InvalidTransition => e
				if(fare.is_cancelled)
					ok
				else
					raise e
				end
			rescue ApiExceptions::RideNotAssignedToThisDriverException
				error! $!.message, 403, 'X-Error-Detail' => $!.message
			end
		end


		desc "Rider cancelled fare"
		params do
			requires :fare_id, type: Integer
		end
		post :rider_cancelled do
			authenticate!
			# TODO rider should only be able to cancel their own ride
      fare = Fare.find(params[:fare_id])
			begin

				if( !fare.riders.any?{ |r| current_user.id = fare.id } )
					raise ApiExceptions::RideNotAssignedToThisRiderException
				end
        fare.rider_cancelled!(current_user)
				ok
			rescue AASM::InvalidTransition => e
				if(fare.is_cancelled)
					ok
				else
					raise e
				end
			rescue ApiExceptions::RideNotAssignedToThisRiderException
				forbidden $!
			end
		end


		desc "Driver picked up rider"
		params do
			requires :fare_id, type: Integer
			optional :rider_id, type: Integer
		end
		post :pickup do
			Rails.logger.debug params
			authenticate!
			# TODO validate driver and or rider is matched to ride
			begin
				fare = Fare.find(params[:fare_id])
				if fare.driver.id != current_user.id
					raise ApiExceptions::RideNotAssignedToThisDriverException
				end

				if(params[:rider_id].nil?)
          fare.pickup!
				else
					rider = Rider.find(params[:rider_id])
          fare.pickup! rider
				end
				ok
			rescue ApiExceptions::RideNotAssignedToThisDriverException
				forbidden $!
			end
		end


		desc "Driver dropped off rider(s)"
		params do
			requires :fare_id, type: Integer
		end
		post :arrived do
			authenticate!
			begin
				fare = Fare.find(params[:fare_id])
				if fare.driver.id != current_user.id
					raise ApiExceptions::RideNotAssignedToThisDriverException
				end

        fare = Fare.find(params[:fare_id])
				earnings = fare.cost * 0.8
				# process the payment
				# TODO Refactor into delayed job
				# and move this code to a model layer, and separate into better units
        fare.riders.each do |rider|
					begin
						request = rider.rides.where( :fare_id => fare.id ).first

						payment = Payment.new
						payment.driver = fare.driver
						payment.fare = fare
						payment.rider = rider
						payment.ride = request
						payment.amount_cents = ride.cost_per_rider
						payment.driver_earnings_cents = earnings / ride.riders.count
						payment.stripe_customer_id = rider.stripe_customer_id

						case request.request_type
						when 'on_demand'
							payment.initiation = 'On Demand Payment'

							customer = Stripe::Customer.retrieve(rider.stripe_customer_id)
							charge = Stripe::Charge.create(
								:amount => payment.amount_cents,
								:currency => "usd",
								:customer => customer.id,
								:description => "Charge for Voco Ride: " + fare.meeting_point_place_name + " to " + fare.drop_off_point_place_name
							)
							if charge.paid == true
								payment.stripe_charge_status = 'Success'
								payment.captured_at = DateTime.now
								payment.paid = true
							else
								payment.stripe_charge_status = 'Failed'
							end

						when 'commuter'

							payment.initiation = 'Commuter Card'

							# refill commuter card if necessary
							tries = 0
							begin
								if rider.commuter_balance_cents < ride.cost_per_rider 
									# fill the commuter card
									if rider.commuter_refill_amount_cents <= 0
										raise "Commuter refill not set"
									end

									paid = PaymentsHelper.autofill_commuter_card rider
									if paid == true
										raise "retry"
									else
										raise "Failed to refill commuter card"
									end
								end
							rescue
								if $!.to_s == 'retry'
									Rails.logger.debug 'rescuing for retry'
									tries += 1
									if tries > 2 
										raise "Commuter card refill did not reach required amount after 2 iterations"
									end
									retry
								else
									raise $!
								end
							end

							# pay via commuter card
							payment.stripe_charge_status = 'Paid By Commuter Card'
							payment.paid = true
							rider.commuter_balance_cents -= payment.amount_cents
							rider.save
							
						end
					
					rescue
						payment.stripe_charge_status = 'Error: ' + $!.message
						Rails.logger.debug $!.message

					ensure
						payment.save
					end

				end
				fare.arrived!

				# either way notify the driver
				response = Hash.new
				response['amount'] = fare.cost
				response['driver_earnings'] = earnings
				response

			rescue ApiExceptions::RideNotAssignedToThisDriverException
				forbidden $!
			end
		end

		end
end
