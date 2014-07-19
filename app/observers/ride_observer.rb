class RideObserver < ActiveRecord::Observer

	def scheduled(ride)
		Rails.logger.debug "RideObserver::scheduled"
		# send push messages to clear dialog for other drivers
		send_offer_closed_messages ride

		# and send push messages to notify rider(s) that the ride has been found
		ride.riders.each do |rider|
			Rails.logger.debug "notifying rider"
			Rails.logger.debug rider
			request = ride.ride_requests.where(user_id: rider.id).first
			rider.devices.each do |d|
				if(d.push_token.nil?)
					next	
				end
				n = PushHelper::push_message(d)
				n.alert = "Ride Found!"
				n.data = { type: :ride_found, ride_id: ride.id, request_id: request.id,
						request_type: request.request_type,
						meeting_point_place_name: ride.meeting_point_place_name,
						drop_off_point_place_name: ride.drop_off_point_place_name }
				n.save!
			end
		end
	end

	def driver_assigned(ride)
		Rails.logger.debug 'observer: driver_assigned'
		# if this is a ride assigned by the scheduler (rather than accepted) notify the driver
		Rails.logger.debug ride.driver
		Rails.logger.debug ride.driver.devices
		ride.driver.devices.each do |d|
				if(d.push_token.nil?)
					next
				end
				n = PushHelper::push_message(d)
				n.alert = "Ride Assigned"
				n.data = { type: :ride_assigned, ride_id:ride.id }
				Rails.logger.debug n
				n.save!
		end
				
	end

	def retracted(ride)
		send_offer_closed_messages ride
	end

	def ride_cancelled_by_rider(ride)
		Rails.logger.stack.debug 'ride_cancelled_by_rider ' + ride.to_s
		ride.driver.devices.each do |d|
				if(d.push_token.nil?)
					next	
				end
				n = PushHelper::push_message(d)
				n.alert = "Ride Cancelled!"
				n.data = { type: :ride_cancelled_by_rider, ride_id: ride.id }
				n.save!
				Rails.logger.stack.debug "push sent " + n.data
		end
	end

	def ride_cancelled_by_driver(ride)
		ride.riders.each do |rider|
			rider.devices.each do |d|
				if(d.push_token.nil?)
					next	
				end
				n = PushHelper::push_message(d)
				n.alert = "Ride Cancelled!"
				n.data = { type: :ride_cancelled_by_driver, ride_id: ride.id }
				n.save!
			end
		end
	end

	def ride_completed(ride)
		Rails.logger.debug('RideObserver::ride_completed')
		ride.riders.each do |rider|

			payment = ride.payments.where( :rider_id => rider.id ).first

			rider.devices.each do |d|
				if(d.push_token.nil?)
					next	
				end
				n = PushHelper::push_message(d)
				if payment.paid == true
					n.alert = "Receipt For Your Ride"
					n.data = { type: :ride_receipt, ride_id: ride.id, amount: payment.amount_cents }
				else
					n.alert = "Problem Processing Payment For Your Ride"
					n.data = { type: :ride_payment_problem, ride_id: ride.id, amount: payment.amount_cents }
				end
				n.save!
			end
		end
	end

	def send_offer_closed_messages ride 	
		ride.offers.offer_closed_delivered.each do |offer|
			Rails.logger.stack.debug 'ride_offer_closed ' + ride.to_s + offer.to_s
			driver = offer.driver	
			driver.devices.each do |d|
				if(d.push_token.nil?)
					next	
				end
				n = PushHelper::push_message(d)
				n.alert = ""
				n.content_available = true
				n.data = { type: :ride_offer_closed, offer_id: offer.id, ride_id: ride.id }
				n.save!
			end
		end
	end


end
