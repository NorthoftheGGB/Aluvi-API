class FareObserver < ActiveRecord::Observer

	def scheduled(fare)
		Rails.logger.debug "FareObserver::scheduled"
		# send push messages to clear dialog for other drivers
		send_offer_closed_messages fare


	end

	def driver_assigned(fare)
		Rails.logger.debug 'observer: driver_assigned'
		# if this is a ride assigned by the scheduler (rather than accepted) notify the driver
		fare.driver.devices.each do |d|
				if(d.push_token.nil? || d.push_token == '')
					next
				end
				n = PushHelper::push_message(d)
				n.alert = "Fare Assigned"
				n.data = { type: :fare_assigned, fare_id:fare.id }
				Rails.logger.debug n
				n.save!
		end
				
	end

	def retracted(fare)
		send_offer_closed_messages fare
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
				#Rails.logger.stack.debug "push sent " + n.data
		end
	end

	def fare_cancelled_by_driver(fare)
		fare.riders.each do |rider|
			rider.devices.each do |d|
				if(d.push_token.nil? || d.push_token == '')
					next	
				end
				n = PushHelper::push_message(d)
				n.alert = "Ride Cancelled!"
				n.data = { type: :fare_cancelled_by_driver, fare_id: fare.id }
				n.save!
			end
		end
	end

	def fare_completed(fare)
		Rails.logger.debug('FareObserver::ride_completed')
		fare.riders.each do |rider|

			payment = fare.payments.where( :rider_id => rider.id ).first

			rider.devices.each do |d|
				if(d.push_token.nil? || d.push_token == '')
					next	
				end
				n = PushHelper::push_message(d)
				if payment.paid == true
					n.alert = "Receipt For Your Ride"
					n.data = { type: :ride_receipt, fare_id: fare.id, amount: payment.amount_cents }
				else
					n.alert = "Problem Processing Payment For Your Ride"
					n.data = { type: :ride_payment_problem, fare_id: fare.id, amount: payment.amount_cents }
				end
				n.save!
			end
		end
	end

	def send_offer_closed_messages fare
		fare.offers.offer_closed_delivered.each do |offer|
			driver = offer.driver	
			driver.devices.each do |d|
				if(d.push_token.nil? || d.push_token == '')
					next	
				end
				n = PushHelper::push_message(d)
				n.alert = ""
				n.content_available = true
				n.data = { type: :offer_closed, offer_id: offer.id, fare_id: fare.id }
				n.save!
			end
		end
	end


end
