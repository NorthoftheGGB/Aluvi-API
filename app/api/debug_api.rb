class DebugAPI < Grape::API
	version 'v2', using: :path
	format :json
	formatter :json, Grape::Formatter::Jbuilder

	resources :debug do
		desc "Purge users schedule"
		post :purge do
			Rails.logger.debug "HELLO"
			authenticate!
			rides = current_user.as_rider.rides
			Rails.logger.debug "rides"
			rides.destroy_all
			ok
		end

		post :purge_all do
			authenticate!
			#not yet
		end

		desc "Schedule Commutes"
		post :schedule_commute do
			Scheduler.build_commuter_trips
		end
	end
end
