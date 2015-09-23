class DebugAPI < Grape::API
	version 'v2', using: :path
	format :json
	formatter :json, Grape::Formatter::Jbuilder

	resources :debug do
		desc "Purge users schedule"
		post :purge do
			Rails.logger.debug "HELLO"
			authenticate!
			current_user.as_rider.rides.active.each do |ride|
        Rails.logger.debug 'hi'
        TicketManager.cancel_ride ride
      end
      current_user.trips.fulfilled.each do |trip|
        trip.aborted!
      end
      current_user.trips.requested.each do |trip|
        trip.aborted!
      end
			Rails.logger.debug "rides"
			ok
		end

    desc "Doesnt do anything yet"
		post :purge_all do
			authenticate!
			#not yet
		end

		desc "Schedule Commutes"
		post :schedule_commute do
			authenticate!
      Rails.logger.debug 'ok'
			Scheduler.build_commuter_trips
      Rails.logger.debug 'ko'
		end
	end
end
