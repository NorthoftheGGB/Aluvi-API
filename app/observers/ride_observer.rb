class RideObserver < ActiveRecord::Observer

	def requested(ride)

		Rails.logger.debug "Got :requested in RideRequestObserver"
		# this is where the scheduler needs to be notified, or a flag set

		if(ride.request_type == "on_demand")
			# for now, sidestep the scheduler and just send push notifications out to the drivers
			# when this is an on demand request, for commuter it MUST go through the scheduler to work at all
			
			if self.get_potential_drivers(ride.fare).count == 0
				ride.rider.devices.each do |d|
					n = PushHelper::push_message(d)	
					n.alert = "Ride Requested!"
					n.data = { type: :no_drivers_available, request_id: ride.id }
					n.save!
				end
			else
				offer_to_drivers(ride.fare)
			end
		end	
	end

	def get_potential_drivers fare
		if(fare.riders[0].demo)
			drivers = Driver.demo_drivers
		else
			drivers = Driver.available_drivers
		end
		drivers
	end

	# this would be a callback from the scheduler somewhere
	def offer_to_drivers(fare)

		drivers = self.get_potential_drivers(fare)

		drivers.each do |driver|
			if fare.riders.include?(driver)
				next
			end
			Rails.logger.debug driver.id
			# Every device used by an available driver gets a push notification if they are available
			# this solves any multi-device problems, driver is the key entity in delivery of this particular push
			if(driver.devices.count > 0 )
				offer = driver.offer_fare(fare)
				driver.devices.each do |d|
					if(d.push_token.nil? || d.push_token == '')
						next	
					end
					n = PushHelper::push_message(d)
					n.alert = "Fare Available!"
					n.data = { type: :offer, offer_id: offer.id, fare_id: fare.id,
						meeting_point_place_name: fare.meeting_point_place_name,
						drop_off_point_place_name: fare.drop_off_point_place_name }
					n.save!
				end
			end	
		end
		Rails.logger.debug "Sent push notifications to drivers"

	end

	def scheduled(fare)
		# this is where we send a push message to the user letting them know their ride is coming
		# i.e. we update their state

	end


end
