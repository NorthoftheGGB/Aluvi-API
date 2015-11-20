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
		post :commute, jbuilder: 'v2/tickets' do
			authenticate!
      Rails.logger.debug params

      # pickup time must be in the future
      if params['departure_pickup_time'].past?
        error! "departure_pickup_time must be in the future", 406 
      end

      if invalid_longitude_range( params[:departure_longitude]) || invalid_latitude_range( params[:departure_latitude] )
        error! "departure coordinate outside of range", 406 
      end

      if invalid_longitude_range( params[:destination_longitude]) || invalid_latitude_range( params[:destination_latitude] )
        error! "destination coordinate outside of range", 406 
      end

      hour = DateTime.now.in_time_zone.strftime("%H").to_i
      day = Date.today
      if hour > 22
        day = day + 1
      end
      if hour > 22 || hour < 5
        day_string = day.strftime("%d").to_i.ordinalize
        #error! "It's past the cutoff to schedule a ride for the " + day_string + ". You can request a ride for the following at after 5 am."
      end

			# check for prexisting commuter ride on this date
			rides_today = Ride.active.where(rider_id: current_user.id).where(request_type: 'commuter').where('rides.pickup_time > ?', params['departure_pickup_time'].beginning_of_day)
			if rides_today.length > 1
				conflict 'Commute request already exists for this day'
      elsif current_user.payment_mode == 0 && params[:driving] == false && !current_user.as_rider.funding_available_for_trip
        payment_method_required 
			else
        Rails.logger.debug current_rider
				trip = TicketManager.request_commute(
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
        tickets
			end
		end



		desc "Get requested and underway ride requests"
		get 'tickets', jbuilder: 'v2/tickets' do
			authenticate!
			ok
      tickets
		end

		desc "User cancelled a ride"
		params do
			requires :ride_id, type: Integer
		end
		post :cancel, jbuilder: 'v2/tickets' do
			authenticate!

			ride = nil

			# TODO rider should only be able to cancel their own ride
			# TODO move this logic to TicketManager in lib/
			ActiveRecord::Base.transaction do
				begin
					ride = Ride.find(params[:ride_id])
					TicketManager.cancel_ride ride
				rescue AASM::InvalidTransition => e
					if(ride.cancelled?)
						# we are ok
					elsif(ride.aborted? && !ride.fare.nil? && ride.fare.is_cancelled)
						# we are still ok
					else
						raise e
					end
				rescue ActiveRecord::RecordNotFound => e
					if fare.nil?
						# also OK
					else
						raise e
					end
				end
			end
			ok
      tickets

		end

		desc "Driver picked up rider"
		params do
			requires :ride_id, type: Integer # ride_id of the driver's ride
			optional :rider_id, type: Integer
		end
		post :pickup, jbuilder: 'v2/tickets' do
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
        tickets
			rescue ApiExceptions::RideNotAssignedToThisDriverException
				forbidden $!
			end
		end


		desc "Driver dropped off rider(s)"
		params do
			requires :ride_id, type: Integer
		end
		post :arrived, jbuilder: 'v2/tickets' do
			authenticate!
			begin
				ride = Ride.find(params[:ride_id])
				fare = ride.fare
				if fare.driver.id != current_user.id
					raise ApiExceptions::RideNotAssignedToThisDriverException
				end

				TicketManager.fare_completed fare

        ok
        tickets

      rescue AASM::InvalidTransition => e
        Rails.logger.error "ERROR: Invalid Transition"
        Rails.logger.error e
        if fare.completed?
          ok
          tickets
        else
          raise e
        end

			rescue ApiExceptions::RideNotAssignedToThisDriverException
				forbidden $!
			end
		end

		desc "Cancel an entire trip"
		delete 'trips/:trip_id' do
			authenticate!
			begin
				trip = Trip.find(params[:trip_id])
				TicketManager.cancel_trip(trip)
				ok
        tickets
			rescue
        Rails.logger.error $!
				#Rails.logger.error $!.backtrace.join("\n")
				Rails.logger.debug params[:trip_id]
				error! $!.message, 400, 'X-Error-Detail' => $!.message
			end
				
		end

		desc "Get all pickup points"
		params do
		end
		get :pickup_points, jbuilder: 'v2/pickup_points' do
			#authenticate!
			pickup_points = Route.select(:origin).select('count(rider_id) as number_of_riders').group(:origin)
			@points = pickup_points

		end

		desc "Update Route"
		params do
			optional :origin, type: Hash do
				requires :latitude
				requires :longitude
			end
			optional :origin_place_name, type: String
			optional :pickup_zone_center, type: Hash do
				requires :latitude
				requires :longitude
			end
			optional :pickup_zone_center_place_name, type: String
			requires :destination, type: Hash do
				requires :latitude
				requires :longitude
			end
			requires :destination_place_name, type: String
			optional :pickup_time, type: String
			optional :return_time, type: String
			requires :driving, type: Boolean
		end
		post :route, jbuilder: 'route' do
			authenticate!
			Rails.logger.debug params
			# assume single route per user	
			route = Route.where('rider_id' => current_user.id).first
			if route.nil?
				route = Route.new
			end

			origin = RGeo::Geographic.spherical_factory( :srid => 4326 ).point(params[:origin][:longitude], params[:origin][:latitude])
			destination = RGeo::Geographic.spherical_factory( :srid => 4326 ).point(params[:destination][:longitude], params[:destination][:latitude])
			pickup_zone_center = RGeo::Geographic.spherical_factory( :srid => 4326 ).point(params[:pickup_zone_center][:longitude], params[:pickup_zone_center][:latitude])
			Rails.logger.debug destination
			route.rider = current_user.as_rider
			route.origin = origin;
			route.destination = destination;
			route.pickup_zone_center = pickup_zone_center
			route.origin_place_name = params[:origin_place_name];
			route.destination_place_name = params[:destination_place_name];
			route.pickup_zone_center_place_name = params[:pickup_zone_center_place_name];
			route.pickup_time = params[:pickup_time];
			route.return_time = params[:return_time];
			route.driving = params[:driving];
			route.save
			ok
			@route = route

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

    desc "Payment Details"
    get :receipts, jbuilder: "v2/receipts" do
      authenticate!
      Rails.logger.debug "ok"
      @receipts = current_user.receipts
      Rails.logger.debug "ko"
    end
	end
end
