class RideRequestObserver < ActiveRecord::Observer

	def requested(ride_request)
		Rails.logger.debug "Got :requested in RideRequestObserver"
		# this is where the scheduler needs to be notified, or a flag set

		# for now, sidestep the scheduler and just send push notifications out to the drivers
		notifications = Array.new

		Driver.available_drivers.each do |driver|
			# Every device used by a driver gets a push notification if they are available
			# this solves any multi-device problems, driver is the key entity in delivery
			driver.devices.each do |d|
				Rails.logger.debug(d.push_token)
				n =  APNS::Notification.new(d.push_token, 'Ride Requested!' );
				notifications.push( n )
			end
		end

		APNS.send_notifications(notifications)
		Rails.logger.debug "Sent push notifications to drivers"
	end

	def scheduled(ride_request)
		# this is where we send a push message to the user letting them know their ride is coming
		# i.e. we update their state

	end


end
