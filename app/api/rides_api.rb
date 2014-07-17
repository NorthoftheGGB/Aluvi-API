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
			optional :desired_arrival, type: Date
		end
		post :request do
			authenticate!
			case params[:type]
			when 'on_demand'
					ride_request = OnDemandRideRequest.create!(params[:type],
																						 RGeo::Geographic.spherical_factory( :srid => 4326 ).point(params[:departure_longitude], params[:departure_latitude]),
																						 params[:departure_place_name],
																						 RGeo::Geographic.spherical_factory( :srid => 4326 ).point(params[:destination_longitude], params[:destination_latitude]),
																						 params[:destination_place_name],
																						 current_user.id
																						)
			when 'commuter'
					ride_request = CommuterRideRequest.create!(params[:type],
																						 RGeo::Geographic.spherical_factory( :srid => 4326 ).point(params[:departure_longitude], params[:departure_latitude]),
																						 params[:departure_place_name],
																						 RGeo::Geographic.spherical_factory( :srid => 4326 ).point(params[:destination_longitude], params[:destination_latitude]),
																						 params[:destination_place_name],
																						 params[:desired_arrival],
																						 current_user.id
																						)
			else
				raise "No request type set"
			end

			ride_request.request!

			if params[:type] == 'commuter'
				if current_user.demo
					# demoing subsystem
					demo_ride_requests = RideRequest.where( :request_type => 'commuter' ).where( :state => 'requested').includes( :user ).where( :users => { demo: true  } ) 
					if demo_ride_requests.count > 2
						Rails.logger.debug 'scheduling DEMO commuter ride'
						ActiveRecord::Base.transaction do
							# need to DRY this with the commuter ride requests controller
							ride = Ride.assemble_ride_from_requests demo_ride_requests		
							ride.meeting_point_place_name = RidesHelper::reverse_geocode ride.meeting_point
							ride.drop_off_point_place_name = RidesHelper::reverse_geocode  ride.drop_off_point
							drivers = User.demo_drivers
							ride.schedule!( nil, DateTime.now, drivers[0], drivers[0].cars.first )
						end
					end
				end
			end

			rval = Hash.new
			rval[:request_id] = ride_request.id
			rval

		end
		
		desc "Cancel a ride request"
		params do
			requires :request_id, type: Integer
		end
		post "request/cancel" do
			authenticate!
			begin
				ride_request = RideRequest.find(params[:request_id])
				if(ride_request.user != current_user )
					raise ApiExceptions::WrongUserForEntityException
				end
				if !ride_request.ride.nil? && ride_request.ride.scheduled?
					#if ride found has yet been delivered to phone, cancel ride instead of request anyway
					ride_request.ride.rider_cancelled! ride_request.user
				else
					ride_request.cancel!
				end
				ok
			rescue ApiExceptions::WrongUserForEntityException
				Rails.logger.debug $!
				forbidden $!
			rescue AASM::InvalidTransition => e 
				Rails.logger.debug e
				forbidden e
			rescue
				error! $!.message, 403, 'X-Error-Detail' => $!.message
			end

		end

		desc "Update list of offered rides"
		get 'offers', jbuilder: 'offer' do
			authenticate!
			@offers = current_user.offered_rides.open_offers
			current_user.offered_rides.undelivered_offers.each do |offer|
				offer.offer_delivered!
			end
			@offers
		end

		desc "Update list of rides assigned to driver"
		get 'rides', jbuilder: 'rides' do
			authenticate!
			if current_user.driver_role.nil?
				forbidden
				return
			end
			@rides = current_user.driver_rides.active

		end

		desc "Get requested and underway ride requests"
		get 'requests', jbuilder: 'requests' do
			authenticate!
			@requests = current_user.ride_requests.select('*, ride_requests.id as request_id').joins('JOIN rides ON rides.id = ride_requests.ride_id').where( state: ["requested", "scheduled"])
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

		desc "Get specific ride details"
		get ':id' do
			authenticate!
			ride = Ride.find(params[:id])
			unless ride.nil?
				if current_user.involved_in_ride ride
					ride		
				else
					forbidden
				end
			else
				not_found
			end
		end


		desc "Driver accepted ride"
		params do
			requires :ride_id, type: Integer
		end
		post :accepted do
			authenticate!
			ride = Ride.find(params[:ride_id])

			unless(["created", "unscheduled"].include? ride.state)
				if( ride.driver == current_user )
					# ok to return HTTP success
					ok
				else
					error! 'Ride no longer available', 403, 'X-Error-Detail' => 'Ride is no longer available'
					return
				end
			else 
				driver = Driver.find(current_user.id)
				driver.accepted_ride(ride)
				ok
			end

		end

		desc "Driver declined ride"
		params do
			requires :ride_id, type: Integer
		end
		post :declined do
			authenticate!
			ride = Ride.find(params[:ride_id])
			if(ride.state != "created")
				if( ride.driver == current_user )
					error! 'Already assigned to this driver', 404, 'X-Error-Detail' => 'Already assigned to this driver'
				else
					error! 'Ride no longer available', 403, 'X-Error-Detail' => 'Ride is no longer available'
					return
				end
			end

			current_user.declined_ride(ride)
			ok

		end


		desc "Driver cancelled ride"
		params do
			requires :ride_id, type: Integer
		end
		post :driver_cancelled do
			authenticate!
			ride = Ride.find(params[:ride_id])
			begin
				if ride.driver.id != current_user.id
					raise ApiExceptions::RideNotAssignedToThisDriverException
				end
				ride.driver_cancelled!
				ok
			rescue AASM::InvalidTransition => e
				if(ride.is_cancelled)
					ok
				else
					raise e
				end
			rescue ApiExceptions::RideNotAssignedToThisDriverException
				error! $!.message, 403, 'X-Error-Detail' => $!.message
			end
		end


		desc "Rider cancelled ride request"
		params do
			requires :ride_id, type: Integer
		end
		post :rider_cancelled do
			authenticate!
			# TODO rider should only be able to cancel their own ride
			ride = Ride.find(params[:ride_id])
			begin

				if( !ride.riders.any?{ |r| current_user.id = ride.id } )
					raise ApiExceptions::RideNotAssignedToThisRiderException
				end
				ride.rider_cancelled!(current_user)
				ok
			rescue AASM::InvalidTransition => e
				if(ride.is_cancelled)
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
			requires :ride_id, type: Integer
			optional :rider_id, type: Integer
		end
		post :pickup do
			Rails.logger.debug params
			authenticate!
			# TODO validate driver and or rider is matched to ride
			begin
				ride = Ride.find(params[:ride_id])
				Rails.logger.debug ride.driver.id
				Rails.logger.debug current_user.id
				if ride.driver.id != current_user.id
					raise ApiExceptions::RideNotAssignedToThisDriverException
				end

				if(params[:rider_id].nil?)
					ride.pickup!
				else
					rider = Rider.find(params[:rider_id])
					ride.pickup! rider
				end
				ok
			rescue ApiExceptions::RideNotAssignedToThisDriverException
				forbidden $!
			end
		end


		desc "Driver dropped off rider(s)"
		params do
			requires :ride_id, type: Integer
		end
		post :arrived do
			authenticate!
			begin
				ride = Ride.find(params[:ride_id])
				if ride.driver.id != current_user.id
					raise ApiExceptions::RideNotAssignedToThisDriverException
				end

				ride = Ride.find(params[:ride_id])
				earnings = ride.cost * 0.8
				# process the payment
				# TODO Refactor into delayed job
				# and move this code to a model layer
				ride.riders.each do |rider|
					begin
						payment = Payment.new
						payment.driver = ride.driver
						payment.fare = ride
						payment.rider = rider
						payment.ride = rider.ride_requests.where( :ride_id => ride.id ).first 
						payment.amount_cents = ride.cost / ride.riders.count	
						payment.driver_earnings_cents = earnings / ride.riders.count
						payment.stripe_customer_id = rider.stripe_customer_id
						payment.initiation = 'On Demand Payment'

						customer = Stripe::Customer.retrieve(rider.stripe_customer_id)
						charge = Stripe::Charge.create(
							:amount => payment.amount_cents,
							:currency => "usd",
							:customer => customer.id,
							:description => "Charge for Voco Ride: " + ride.meeting_point_place_name + " to " + ride.drop_off_point_place_name
						)
						if charge.paid == true
							payment.stripe_charge_status = 'success'
							payment.captured_at = DateTime.now
						else
							payment.stripe_charge_status = 'failed'
						end

					rescue
						payment.stripe_charge_status = 'error ' + $!.message

					ensure
						payment.save
					end

				end
				ride.arrived!

				# either way notify the driver
				response = Hash.new
				response['amount'] = ride.cost
				response['driver_earnings'] = earnings
				response

			rescue ApiExceptions::RideNotAssignedToThisDriverException
				forbidden $!
			end
		end

		end
end
