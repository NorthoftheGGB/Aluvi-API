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
			requires :destination_latitude, type: BigDecimal
			requires :destination_longitude, type: BigDecimal
		end
		post :request do
			authenticate!
			ride_request = RideRequest.create!(params[:type],
																				 RGeo::Geographic.spherical_factory.point(params[:departure_latitude], params[:departure_longitude]),
																				 RGeo::Geographic.spherical_factory.point(params[:destination_latitude], params[:destination_longitude]),
																				 current_user.id
																				)
			ride_request.request!
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
				ride_request.cancel!
				ok
			rescue ApiExceptions::WrongUserForEntityException
				forbidden $!
			rescue
				error! $!.message, 403, 'X-Error-Detail' => $!.message
			end

		end

		desc "Update list of offered or underway rides"
		get 'offers', jbuilder: 'offer' do
			authenticate!
			@offers = current_user.offered_rides.open_offers
			current_user.offered_rides.undelivered_offers.each do |offer|
				offer.offer_delivered!
			end
			@offers
		end

		desc "Get requested and underway rides"
		get jbuilder: 'rides' do
			authenticate!
			@scheduled_rides = current_user.rides.scheduled
			@scheduled_rides.each do |ride|
				# mark as delivered here if we like
			end
			@scheduled_rides
		end


		desc "Driver accepted ride"
		params do
			requires :ride_id, type: Integer
		end
		post :accepted do
			authenticate!
			ride = Ride.find(params[:ride_id])

			if(ride.state != "created")
				if( ride.driver == current_user )
					# ok to return HTTP success
					ok
				else
					error! 'Ride no longer available', 403, 'X-Error-Detail' => 'Ride is no longer available'
					return
				end
			else 
				current_user.accepted_ride(ride)
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
				if ride.driver != current_user
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
			rescue RideNotAssignedToThisDriverException
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
				if( !ride.riders.contains(current_user) )
					raise RideNotAssignedToThisRiderException
				end
				ride.rider_cancelled!(current_user)
				ok
			rescue AASM::InvalidTransition => e
				if(ride.is_cancelled)
					ok
				else
					raise e
				end
			rescue RideNotAssignedToThisRiderException
				forbidden $!
			end
		end


		desc "Driver picked up rider"
		params do
			requires :ride_id, type: Integer
			optional :rider_id, type: Integer
		end
		post :pickup do
			authenticate!
			# TODO validate driver and or rider is matched to ride
			begin
				ride = Ride.find(params[:ride_id])
				if ride.driver != current_user
					raise RideNotAssignedToThisDriverException
				end

				if(params[:rider_id].nil?)
					ride.pickup!
				else
					rider = Rider.find(params[:rider_id])
					ride.pickup! rider
				end
				ok
			rescue RideNotAssignedToThisDriverException
				forbidden $!
			end
		end


		desc "Driver dropped off rider(s)"
		params do
			requires :ride_id, type: Integer
			optional :rider_id, type: Integer
		end
		post :arrived do
			authenticate!
			begin
				ride = Ride.find(params[:ride_id])
				if ride.driver != current_user
					raise RideNotAssignedToThisDriverException
				end

				ride = Ride.find(params[:ride_id])
				if(params[:rider_id].nil?)
					ride.arrived!
				else
					rider = Rider.find(params[:rider_id])
					#ride.arrived! rider
					ride.arrived! # separate arrivals per ride not currently supported
				end
				ok
			rescue RideNotAssignedToThisDriverException
				forbidden $!
			end
		end

	end
end
