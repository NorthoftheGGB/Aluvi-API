class RidesAPI< Grape::API
	version 'v1', using: :header, vendor: 'voco'
	format :json
	formatter :json, Grape::Formatter::Jbuilder

	resources :rides do

		desc "Request Commuter Trip "
		params do
			requires :departure_latitude, type: BigDecimal
			requires :departure_longitude, type: BigDecimal
			requires :departure_place_name, type: String
			requires :destination_latitude, type: BigDecimal
			requires :destination_longitude, type: BigDecimal
			requires :destination_place_name, type: String
			requires :departure_pickup_time, type: DateTime
			requires :return_pickup_time, type: DateTime
			optional :driving, type: Boolean
		end
		post :commute do
			Rails.logger.debug "hello"
			Rails.logger.debug params
			authenticate!

			outgoing_ride = TripController.request_commute_leg(
				RGeo::Geographic.spherical_factory( :srid => 4326 ).point(params[:departure_longitude], params[:departure_latitude]),
				params[:departure_place_name],
				RGeo::Geographic.spherical_factory( :srid => 4326 ).point(params[:destination_longitude], params[:destination_latitude]),
				params[:destination_place_name],
				params[:departure_pickup_time],
				params[:driving],
				current_rider,
				nil
			)

			return_ride = TripController.request_commute_leg(
				RGeo::Geographic.spherical_factory( :srid => 4326 ).point(params[:destination_longitude], params[:destination_latitude]),
				params[:destination_place_name],
				RGeo::Geographic.spherical_factory( :srid => 4326 ).point(params[:departure_longitude], params[:departure_latitude]),
				params[:departure_place_name],
				params[:return_pickup_time],
				params[:driving],
				current_rider,
				outgoing_ride.trip_id
			)

			rval = Hash.new
			rval[:outgoing_ride_id] = outgoing_ride.id
			rval[:return_ride_id] = return_ride.id
			rval[:trip_id] = outgoing_ride.trip_id
			rval
		end




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
        when 'commuter'

          ride = TripController.request_commute_leg(
              RGeo::Geographic.spherical_factory( :srid => 4326 ).point(params[:departure_longitude], params[:departure_latitude]),
              params[:departure_place_name],
              RGeo::Geographic.spherical_factory( :srid => 4326 ).point(params[:destination_longitude], params[:destination_latitude]),
              params[:destination_place_name],
              params[:pickup_time],
              params[:driving],
              current_rider,
              params[:trip_id]
          )

			else
				raise "No request type set"
			end


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
                fare.pickup_time = DateTime.now
                fare.driver = drivers[0]
                fare.car = drivers[0].cars.first
							end
						end
					end
				end
			end

			status 200
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
				TripController.cancel_request ride
				status 200
				ok
			rescue ActiveRecord::RecordNotFound
				status 200
				ok
			rescue ApiExceptions::WrongUserForEntityException
		    Rails.loger.debug "WrongUserForEntityException"
				Rails.logger.debug $!
				forbidden $!
      rescue AASM::InvalidTransition => e
				if(ride.state == 'cancelled')
					status 200
					ok
				else
					Rails.logger.error e
					Rails.logger.debug ride.id
					forbidden e
				end
      rescue
        Rails.logger.error $!
				Rails.logger.error $!.backtrace.join("\n")
				error! $!.message, 403, 'X-Error-Detail' => $!.message
			end
		end

		desc "Cancel an entire trip"
		delete 'trips/:trip_id' do
			authenticate!
			begin
				trip = Trip.find(params[:trip_id])
				TripController.cancel_trip(trip)
				status 200
				ok
			rescue
        Rails.logger.error $!
				#Rails.logger.error $!.backtrace.join("\n")
				Rails.logger.debug params[:trip_id]
				error! $!.message, 400, 'X-Error-Detail' => $!.message
			end
				
		end

		desc "Get list of fares assigned to driver"
		get 'fares', jbuilder: 'fares' do
			authenticate!
      begin
        driver = Driver.find(current_user.id)
        @fares = driver.fares.active
      rescue ActiveRecord::RecordNotFound
        @fares = Array.new
      end
		end

		desc "Get requested and underway ride requests"
		get 'tickets', jbuilder: 'tickets' do
			authenticate!
      rider = Rider.find(current_user.id)
      #TODO should only send rides that are in the future
      #however we must send all for now, because orphan cleaning isn't working on iOS side
			@rides = rider.rides #.select('rides.*').joins('JOIN fares ON fares.id = rides.fare_id').where( state: ["requested", "scheduled", "started"])
			@rides.each do |ride|
				# mark as delivered here if we like
			end
			@rides
		end

		desc "Payment Details"
		get :payments do
			authenticate!
			rider = Rider.find(current_user.id)
			rider.payments
		end

		desc "Receipt for Drivers"
		get :earnings, jbuilder: 'earnings' do
			authenticate!
			driver = Driver.find(current_user.id)
			@fares = driver.fares.completed
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

		desc "Driver cancelled fare"
		params do
			requires :fare_id, type: Integer
		end
		post :driver_cancelled do
			authenticate!
			# TODO move this logic to TripController
			begin
        fare = Fare.find(params[:fare_id])
        if fare.driver.id != current_user.id
					raise ApiExceptions::RideNotAssignedToThisDriverException
        end
        if !fare.is_cancelled
          fare.driver_cancelled!
        end
        fare.rides.each do |ride|
          unless ride.aborted?
            ride.abort!
          end
        end
				ok  
			rescue AASM::InvalidTransition => e
				if(fare.is_cancelled)
					ok
				else
					raise e
				end
			rescue ApiExceptions::RideNotAssignedToThisDriverException
				error! $!.message, 403, 'X-Error-Detail' => $!.message
      rescue ActiveRecord::RecordNotFound
        if fare.nil?
          ok
        end
			end
		end


		desc "Rider cancelled fare"
		params do
			requires :fare_id, type: Integer
		end
		post :rider_cancelled do
			authenticate!

			# TODO rider should only be able to cancel their own ride
			begin
				fare = Fare.find(params[:fare_id])
        ride = current_user.as_rider.rides.where(fare_id: params[:fare_id]).first
        unless ride.nil?
          unless ride.aborted?
            ride.abort!
          end
          unless ride.fare.nil?
            unless fare.is_cancelled
             fare.rider_cancelled!(current_user.as_rider)
            end
          end
        end
				ok
      rescue AASM::InvalidTransition => e
        if(fare.is_cancelled && ride.is_aborted)
					ok
				else
					raise e
				end
			rescue ActiveRecord::RecordNotFound => e
				if fare.nil?
					ok
				else
					raise e
				end
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
			  TripController.fare_completed fare

				# either way notify the driver
				response = Hash.new
				response['amount'] = fare.cost
				response['driver_earnings'] = fare.fixed_earnings
				response

			rescue ApiExceptions::RideNotAssignedToThisDriverException
				forbidden $!
			end
		end


		desc "Update Route"
		params do
			requires :origin, type: Hash do
				requires :latitude
				requires :longitude
			end
			requires :origin_place_name, type: String
			requires :destination, type: Hash do
				requires :latitude
				requires :longitude
			end
			requires :destination_place_name, type: String
			requires :pickup_time, type: String
			requires :return_time, type: String
			requires :driving, type: Boolean
		end
		post :route do
			authenticate!
			Rails.logger.debug params
			# assume single route per user	
			route = Route.where('rider_id' => current_user.id).first
			if route.nil?
				route = Route.new
			end

			origin = RGeo::Geographic.spherical_factory( :srid => 4326 ).point(params[:origin][:longitude], params[:origin][:latitude])
			destination = RGeo::Geographic.spherical_factory( :srid => 4326 ).point(params[:destination][:longitude], params[:destination][:latitude])
			Rails.logger.debug destination
			route.rider = current_user.as_rider
			route.origin = origin;
			route.destination = destination;
			route.origin_place_name = params[:origin_place_name];
			route.destination_place_name = params[:destination_place_name];
			route.pickup_time = params[:pickup_time];
			route.return_time = params[:return_time];
			route.driving = params[:driving];
			Rails.logger.debug route
			route.save
			ok

		end

		desc "Get Route"
		get :route, jbuilder: 'route' do
			authenticate!
			# assume single route per user	
			@route = Route.where('rider_id' => current_user.id).first
			if @route.nil?
				not_found	
			else
				@route
			end
		end

		end
end
