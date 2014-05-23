class RideRequestObserver < ActiveRecord::Observer

	def requested(ride_request)
		Rails.logger.debug "Got :requested in RideRequestObserver"
	end

end
