class RidesAPI< Grape::API
	version 'v1', using: :header, vendor: 'voco'
	format :json
	formatter :json, Grape::Formatter::Jbuilder

	resources :rides do

		desc "Get requested and underway ride requests"
		get 'tickets', jbuilder: 'v2/tickets' do
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
	end
end
