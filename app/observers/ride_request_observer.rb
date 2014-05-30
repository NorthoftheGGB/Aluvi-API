class RideRequestObserver < ActiveRecord::Observer

	def requested(ride_request)

		Rails.logger.debug "Got :requested in RideRequestObserver"
		# this is where the scheduler needs to be notified, or a flag set

		# for now, sidestep the scheduler and just send push notifications out to the drivers

		#User.available_drivers.each do |driver|
		User.all.each do |driver|
			Rails.logger.debug driver.id
			# Every device used by an available driver gets a push notification if they are available
			# this solves any multi-device problems, driver is the key entity in delivery of this particular push
			driver.devices.each do |d|
				Rails.logger.debug( "Push: " + d.push_token)
				n = Rpush::Apns::Notification.new
				n.app = Rpush::Apns::App.find_by_name("voco")
				n.device_token = d.push_token
				n.alert = "Ride requested!"
				n.content_available = true
				n.data = { foo: :bar }
				n.save!
			end
		end

		#APNS.send_notifications(notifications)
		Rails.logger.debug "Sent push notifications to drivers"
	end

	def scheduled(ride_request)
		# this is where we send a push message to the user letting them know their ride is coming
		# i.e. we update their state

	end


end
