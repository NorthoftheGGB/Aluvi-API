class RidesAPI< Grape::API
	version 'v1', using: :header, vendor: 'voco'
	format :json

	resources :rides do

		desc "Request a ride"
		params do
			requires :rider_id, type: String
			requires :type, type: String
			requires :departure_latitude, type: BigDecimal
			requires :departure_longitude, type: BigDecimal
			requires :destination_latitude, type: BigDecimal
			requires :destination_longitude, type: BigDecimal
		end
		post :request do
			authenticate!
			destination = RGeo::Geos.factory.point(params[:departure_latitude], params[:departure_longitude])
			ride_request = RideRequest.create!(params[:type],
																				 RGeo::Geos.factory.point(params[:departure_latitude], params[:departure_longitude]),
																				 RGeo::Geos.factory.point(params[:destination_latitude], params[:destination_longitude]))
			ride_request.request!
			#json_string = Jbuilder.encode do |json|
			#	json.request_id = ride_request.id
			#end
			# TODO problem here is that jbuilder already returned a string
			# but then the default grape json encoder escapes it
			rval = Hash.new
			rval[:request_id] = ride_request.id
			rval

		end

		desc "Check for state changes"
		params do
			requires :sequence, type: Integer, desc: "Sequence number of last recorded state change"
		end
		route_param :sequence do
			get do
				authenticate!
			end
		end

		desc "Driver accepted ride"
		params do
			requires :ride_id, type: Integer
			requires :driver_id, type: Integer
		end
		post :accepted do
			authenticate!
			ride = Ride.find(params[:ride_id])
			driver = User.find(params[:driver_id])
			begin
				ride.accepted!(driver)
				true
			rescue
				puts $!, $@
				# ride is no longer available
				# check that if this because it's assigned to THIS driver
				if( ride.driver == driver )
					return "Already assigned to this driver"
				else
					error! 'Ride no longer available', 403, 'X-Error-Detail' => 'Ride is no longer available'
				end
			end

		end

		desc "Driver declined ride"
		params do
			requires :ride_id, type: Integer
			requires :driver_id, type: Integer
		end
		post :declined do
			authenticate!
			ride = Ride.find(params[:ride_id])
			driver = User.find(params[:driver_id])
			begin
				driver.declined_ride(ride)
				true
			rescue
				puts $!, $@
				# ride is no longer able to be delined
				# check that if this because it's assigned to THIS driver
				if( ride.driver == driver )
					# should this case auto-cancel the ride?
					return "Already assigned to this driver, they will have to cancel"
				else
					error! 'Ride no longer available', 403, 'X-Error-Detail' => 'Ride is no longer available'
				end
			end

		end


		desc "Driver cancelled ride"
		params do
			requires :ride_id, type: Integer
			requires :driver_id, type: Integer
		end
		post :driver_cancelled do
			authenticate!
			# TODO driver should only be able to cancel their own ride
			ride = Ride.find(params[:ride_id])
			driver = User.find(params[:driver_id])
			ride.driver_cancelled!
		end


		desc "Rider cancelled ride request"
		params do
			requires :ride_id, type: Integer
			requires :rider_id, type: Integer
		end
		post :rider_cancelled do
			authenticate!
			# TODO rider should only be able to cancel their own ride
			ride = Ride.find(params[:ride_id])
			rider = User.find(params[:rider_id])
			ride.rider_cancelled!(rider)
		end


		desc "Driver picked up rider"
		params do
			requires :ride_id, type: Integer
			requires :driver_id, type: Integer
			optional :rider_id, type: Integer
		end
		post :pickup do
			authenticate!
			# TODO validate driver and or rider is matched to ride
			ride = Ride.find(params[:ride_id])
			if(params[:rider_id].nil?)
				ride.pickup!
			else
				rider = Rider.find(params[:rider_id])
				ride.pickup! rider
			end
		end


		desc "Driver dropped off rider(s)"
		params do
			requires :ride_id, type: Integer
			requires :driver_id, type: Integer
			optional :rider_id, type: Integer
		end
		post :arrived do
			authenticate!
			# TODO validate driver and or rider is matched to ride
			ride = Ride.find(params[:ride_id])
			if(params[:rider_id].nil?)
				ride.arrived!
			else
				rider = Rider.find(params[:rider_id])
				#ride.arrived! rider
				ride.arrived! # separate arrivals per ride not currently supported
			end
		end

	end
end
