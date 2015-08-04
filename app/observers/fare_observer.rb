class FareObserver < ActiveRecord::Observer

	def retracted(fare)
		TripController.send_offer_closed_messages fare
	end

	def fare_cancelled_by_rider(fare)
		fare.driver.devices.each do |d|
				if(d.push_token.nil? || d.push_token == '')
					next	
				end
				n = PushHelper::push_message(d)
				n.alert = "Fare Cancelled!"
				n.data = { type: :fare_cancelled_by_rider, fare_id: fare.id }
				n.save!
				Rails.logger.debug "sending cancel push"
		end
	end

	def fare_cancelled_by_driver(fare)
		fare.rides.where.not( driving: true).each do |ride|
			rider = ride.rider
			rider.devices.each do |d|
				if(d.push_token.nil? || d.push_token == '')
					next	
				end
				n = PushHelper::push_message(d)
				n.alert = "Ride Cancelled!"
				n.data = { type: :fare_cancelled_by_driver, fare_id: fare.id }
				n.save!
				Rails.logger.debug "sending driver cancelled push"
			end
		end
	end




end
