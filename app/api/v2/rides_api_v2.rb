class RidesAPI< Grape::API
	version 'v1', using: :header, vendor: 'voco'
	format :json
	formatter :json, Grape::Formatter::Jbuilder

	resources :rides do

		desc "Get requested and underway ride requests"
		get 'tickets', jbuilder: 'v2/tickets' do
			authenticate!
      rider = Rider.find(current_user.id)
      #TODO should only send rides that are relevant
			@rides = rider.rides.select('rides.*').where('pickup_time > ?', DateTime.now.beginning_of_day) 
			@rides
		end
	end
end
