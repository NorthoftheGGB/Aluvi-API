class RidesAPIV2< Grape::API
	version 'v2', using: :path
	format :json
	formatter :json, Grape::Formatter::Jbuilder

	resources :rides do

		desc "Get requested and underway ride requests"
		get 'tickets', jbuilder: 'v2/tickets' do
			authenticate!
			rider = Rider.find(current_user.id)
			@rides = rider.rides.select('rides.*').where('pickup_time > ?', DateTime.now.beginning_of_day) 
			@rides
		end

		desc "Rider cancelled fare"
		params do
			requires :ride_id, type: Integer
		end
		post :rider_cancelled do
			authenticate!

			# TODO rider should only be able to cancel their own ride
			begin
				ride = current_user.as_rider.rides.where(ride_id: params[:ride_id]).first
				fare = ride.fare
				unless ride.nil?
					unless ride.aborted?
						ride.abort!
					end
					unless ride.fare.nil?
						unless fare.is_cancelled
							fare.ride_cancelled!(ride)
						end
					end
				end
				ok
			rescue AASM::InvalidTransition => e
				if(fare.is_cancelled && ride.aborted?)
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
			requires :ride_id, type: Integer # ride_id of the driver's ride
			optional :rider_id, type: Integer
		end
		post :pickup do
			Rails.logger.debug params
			authenticate!
			# TODO validate driver and or rider is matched to ride
			begin
				ride = Ride.fine(params[:ride_id])
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
				ride = Ride.fine(params[:ride_id])
				fare = ride.fare
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


	end
end
