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
             fare.rider_cancelled!(current_user.as_rider)
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

	end
end
