class RidesAPIV2< Grape::API
	version 'v2', using: :path
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
			authenticate!

			trip = TripController.request_commute(
				RGeo::Geographic.spherical_factory( :srid => 4326 ).point(params[:departure_longitude], params[:departure_latitude]),
				params[:departure_place_name],
				params[:departure_pickup_time],
				RGeo::Geographic.spherical_factory( :srid => 4326 ).point(params[:destination_longitude], params[:destination_latitude]),
				params[:destination_place_name],
				params[:return_pickup_time],
				params[:driving],
				current_rider
			)

			ok
			rval = Hash.new
			rval[:outgoing_ride_id] = trip.rides[0].id
			rval[:return_ride_id] = trip.rides[1].id
			rval[:trip_id] = trip.id
			rval
		end



		desc "Get requested and underway ride requests"
		get 'tickets', jbuilder: 'v2/tickets' do
			authenticate!
			rider = Rider.find(current_user.id)
			@rides = rider.rides.select('rides.*').where('pickup_time > ?', DateTime.now.beginning_of_day) 
			@rides
		end

		desc "User cancelled a ride"
		params do
			requires :ride_id, type: Integer
		end
		post :cancel do
			authenticate!

			# TODO rider should only be able to cancel their own ride
			# TODO move this logic to TripController in lib/
			ActiveRecord::Base.transaction do
				begin
					ride = Ride.find(params[:ride_id])
					ride.cancel_ride
					ok
				rescue AASM::InvalidTransition => e
					if(ride.cancelled?)
						ok
					elsif(ride.aborted? && !ride.fare.nil? && ride.fare.is_cancelled)
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
		end

		desc "Driver picked up rider"
		params do
			requires :ride_id, type: Integer # ride_id of the driver's ride
			optional :rider_id, type: Integer
		end
		post :pickup do
			Rails.logger.debug params
			authenticate!
			# TODO validate driver and or rider is matched to ride
			begin
				ride = Ride.find(params[:ride_id])
				fare = ride.fare
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
			requires :ride_id, type: Integer
		end
		post :arrived do
			authenticate!
			begin
				ride = Ride.find(params[:ride_id])
				fare = ride.fare
				if fare.driver.id != current_user.id
					raise ApiExceptions::RideNotAssignedToThisDriverException
				end

				fare = Fare.find(params[:fare_id])
				TripController.fare_completed fare

				# either way notify the driver
				status 200
				response = Hash.new
				response['amount'] = fare.cost
				response['driver_earnings'] = fare.fixed_earnings
				response

			rescue ApiExceptions::RideNotAssignedToThisDriverException
				forbidden $!
			end
		end

		desc "Cancel an entire trip"
		delete 'trips/:trip_id' do
			authenticate!
			begin
				trip = Trip.find(params[:trip_id])
				TripController.cancel_trip(trip)
				ok
			rescue
        Rails.logger.error $!
				#Rails.logger.error $!.backtrace.join("\n")
				Rails.logger.debug params[:trip_id]
				error! $!.message, 400, 'X-Error-Detail' => $!.message
			end
				
		end

		desc "Get list of fares assigned to driver"

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
			route.save
			ok
			nil

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
