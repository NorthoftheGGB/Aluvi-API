class RideObserver < ActiveRecord::Observer

	def scheduled(ride)
		Rails.logger.debug "RideObserver::scheduled"
		# send push messages to clear dialog for other drivers
		ride.offers.offer_closed_delivered.each do |offer|
			driver = offer.driver	
			driver.devices.each do |d|
				if(d.push_token.nil?)
					next	
				end
				n = Rpush::Apns::Notification.new
				n.app = Rpush::Apns::App.find_by_name("voco")
				n.device_token = d.push_token
				n.alert = ""
				n.content_available = true
				n.data = { type: :ride_offer_closed, offer_id: offer.id, ride_id: ride.id }
				n.save!
			end
		end
	end

	def ride_cancelled_by_rider(ride)
	end

	def ride_cancelled_by_driver(ride)
	end

end
