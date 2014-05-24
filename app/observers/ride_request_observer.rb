class RideRequestObserver < ActiveRecord::Observer

	def requested(ride_request)
		Rails.logger.debug "Got :requested in RideRequestObserver"
		# this is where the scheduler needs to be notified, or a flag set
	end

	def scheduled(ride_request)
		# this is where we send a push message to the user letting them know their ride is coming
		# i.e. we update their state

	end


end
