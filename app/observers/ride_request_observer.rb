class RideRequestObserver < ActiveRecord::Observer

	def requested(ride_request)

		Rails.logger.debug "Got :requested in RideRequestObserver"
		# this is where the scheduler needs to be notified, or a flag set

		if(ride_request.request_type == "on_demand")
			# for now, sidestep the scheduler and just send push notifications out to the drivers
			# when this is an on demand request, for commuter it MUST go through the scheduler to work at all
			
			if self.get_potential_drivers(ride_request.ride).count == 0
				ride_request.user.devices.each do |d|
					n = PushHelper::push_message(d)	
					n.alert = "Ride Requested!"
					n.data = { type: :no_drivers_available, request_id: ride_request.id }
					n.save!
				end
			else
				offer_to_drivers(ride_request.ride)
			end
		end	
	end

	def get_potential_drivers ride
		if(ride.riders[0].demo)
			drivers = Driver.demo_drivers
		else
			drivers = Driver.available_drivers
		end
		drivers
	end

	# this would be a callback from the scheduler somewhere
	def offer_to_drivers(ride)


		drivers = self.get_potential_drivers(ride)

		drivers.each do |driver|
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
					n = PushHelper::push_message(d)
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
