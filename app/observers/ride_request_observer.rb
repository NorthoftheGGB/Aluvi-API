class RideRequestObserver < ActiveRecord::Observer

	def requested(ride_request)

		Rails.logger.debug "Got :requested in RideRequestObserver"
		# this is where the scheduler needs to be notified, or a flag set

		if(ride_request.request_type == "on_demand")
			# for now, sidestep the scheduler and just send push notifications out to the drivers
			# when this is an on demand request, for commuter it MUST go through the scheduler to work at all
			offer_to_drivers(ride_request.ride)
		end	
	end

	# this would be a callback from the schdduler somewhere
	def offer_to_drivers(ride)
		#User.available_drivers.each do |driver|
		User.drivers.each do |driver|
			if ride.riders.include?(driver)
				next
			end
			Rails.logger.debug driver.id
			# Every device used by an available driver gets a push notification if they are available
			# this solves any multi-device problems, driver is the key entity in delivery of this particular push
			if(driver.devices.count > 0 )
				offer = driver.offer_ride(ride)
				driver.devices.each do |d|
					if(d.push_token.nil?)
						next	
					end
					n = Rpush::Apns::Notification.new
					n.app = Rpush::Apns::App.find_by_name("voco")
					n.device_token = d.push_token
					n.alert = "Ride Requested!"
					n.data = { type: :ride_offer, offer_id: offer.id, ride_id: ride.id,
						meeting_point_place_name: ride.meeting_point_place_name,
						drop_off_point_place_name: ride.drop_off_point_place_name }
					n.save!
				end
			end	
		end
		Rails.logger.debug "Sent push notifications to drivers"

	end

	def scheduled(ride_request)
		# this is where we send a push message to the user letting them know their ride is coming
		# i.e. we update their state

	end


end
