class TicketManager

  # Commuter
	def self.request_commute( departure_point, departure_place_name, departure_time, destination_point, destination_place_name, return_time, driving, rider )
      self.rider_not_nil rider
			trip = Trip.new
      aside = TicketManager.request_commute_leg(departure_point, departure_place_name, destination_point, destination_place_name, departure_time, driving, rider, trip.id )
			aside.direction = 'a'
			aside.save
      bside = TicketManager.request_commute_leg(destination_point, destination_place_name, departure_point, departure_place_name, return_time, driving, rider, trip.id)
			bside.direction = 'b'
			bside.save
			trip.rides << aside
			trip.rides << bside
			trip.start_time = departure_time
			trip.save
			trip
	end

	def self.request_ride( departure_point, departure_place_name, destination_point, destination_place_name, pickup_time, driving, rider )
    self.rider_not_nil rider
		trip = Trip.new
		aside = TicketManager.request_commute_leg(departure_point, departure_place_name, destination_point, destination_place_name, pickup_time, driving, rider, trip.id )
		aside.direction = 'a'
		trip.rides << aside
		trip.start_time = pickup_time
		trip.save
		trip
	end

  def self.request_commute_leg( departure_point, departure_place_name, destination_point, destination_place_name, pickup_time, driving, rider, trip_id)
    self.rider_not_nil rider
    ride = CommuterRide.create(
        departure_point,
        departure_place_name,
        destination_point,
        destination_place_name,
        pickup_time,
        driving,
        rider
    )
		ride.trip_id = trip_id
		ride

	end

  def self.rider_not_nil rider
      if rider.nil?
        raise "Rider is Nil"
      end
  end

	def self.driver_cancelled_fare fare
    ActiveRecord::Base.transaction do
      ride = fare.driver.as_rider.rides.where(fare_id: fare.id).first
      unless ride.nil?
        self.cancel_ride ride
      end
    end
	end


	def self.cancel_ride ride
			Rails.logger.info "RIDE_CANCELLED"
			Rails.logger.debug ride.fare
		if ride.fare != nil
			Rails.logger.info "RIDE_CANCELLED"
			Rails.logger.info ride.fare.rides.scheduled.count
			fare = ride.fare
			if( ride.driving? )
				Rails.logger.debug "driving"
				fare.driver_cancelled!
				fare.finished = Time.now
				fare.save
				fare.rides.each do |ride|
					unless ride.aborted?
						ride.abort!
					end
				end
				self.notify_fare_cancelled_by_driver fare

			elsif( fare.rides.scheduled.count == 2 )
				Rails.logger.info "RIDE_CANCELLED: last rider cancelled"
				# this is the only rider, cancel the whole ride
				fare.rider_cancelled!
				fare.finished = Time.now
				fare.save
				fare.rides.scheduled.each do |ride|
					ride.abort!
				end
				self.notify_fare_cancelled_by_rider fare

			else 
				Rails.logger.info 'RIDE_CANCELLED: one rider cancelled'
				unless ride.aborted?
					ride.abort!
				end
			end

      ride.fare.rides.each do |r|
        unless r.trip.nil?
          r.trip.abort_if_no_longer_active

          if r.trip.aborted?
            self.assign_payment_for_trip r.rider, r.trip
          end
        end
      end
		else
			ride.cancel!
      unless ride.trip.nil?
        ride.trip.abort_if_no_longer_active

        if ride.trip.aborted?
          self.assign_payment_for_trip ride.rider, ride.trip
        end
      end
		end
	end




  def self.fare_completed(fare)
    ActiveRecord::Base.transaction do

      fare.riders.each do |rider|
        ride = rider.rides.where( :fare_id => fare.id ).first
        PushHelper.send_notification rider do |notification|
          # this just clears the current ticket at this point
          notification.data = { type: :ride_receipt, fare_id: fare.id, amount: 0 }
          notification.content_available = true # send siliently
        end
      end

      fare.arrived!
      fare.rides.each do |r|
        trip = r.trip
        unless trip.nil?
          trip.complete_if_no_longer_active

          if trip.completed?
            self.assign_payment_for_trip r.rider, trip
          end
        end
      end

    end

  end

  def self.assign_payment_for_trip user, trip
    Rails.logger.debug "assign payment"

    amount = 0
    type = 'not specified'
    trip.rides.each do |ride|
      unless ride.fare.nil?
        if ride.fare.completed?
          if trip.rides[0].driving
            amount = amount + ride.fare.fixed_earnings
            type = 'earning'
          else
            amount = amount - ride.fixed_price
            type = 'trip'
          end
        end
      end
    end

    # check for free ride for rider
    rider = user.as_rider
    if trip.rides[0].driving
      if rider.free_rides > 0
        rider.free_rides = rider.free_rides - 1 
        rider.save
        amount = 0
        type = 'free trip'
      end
    end



    receipt = Receipt.new
    receipt.amount = amount
    receipt.type = type
    receipt.date = DateTime.now
    receipt.trip = trip
    receipt.user = user
    receipt.save
    Rails.logger.debug receipt

    Rails.logger.debug user.commuter_balance_cents
    user.commuter_balance_cents = user.commuter_balance_cents + amount
    user.save

  end

	def self.cancel_trip trip

		ActiveRecord::Base.transaction do
			trip.aborted!
			trip.rides.each do |r|
				if r.state != 'cancelled'
					TicketManager.cancel_ride r
				end
			end
		end
	end

  # Commuter

  def self.calculate_fixed_price_for_commute trip
    # TODO use GIS shapes to calculate fixed price
    trip.rides.where.not(driving: true).each do |ride|
      ride.fixed_price = 500
      ride.save
    end
  end

  def self.calculated_fixed_earnings_for_fare fare
    fare.fixed_earnings = 0
    fare.rides.where.not(driving: true).each do |ride|
      fare.fixed_earnings += ride.fixed_price * 82.25 / 100.0
      fare.save
    end
  end

  def self.notify_fulfilled trip
    send_trip_notification trip do |notification|
      notification.alert = "Your Commute to and from work has been Fulfilled!"
      notification.data = { type: :trip_fulfilled, trip_id: trip.id }
    end
  end

  def self.notify_unfulfilled trip
    Rails.logger.debug trip
    send_trip_notification trip do |notification|
      notification.alert = "We were unable to fulfill your commute to and from work.  Please try again tomorrow"
      notification.data = { type: :trip_unfulfilled, trip_id: trip.id }
    end
  end

  def self.send_trip_notification trip
    PushHelper.send_notification trip.rides[0].rider do |notification|
      yield notification
    end
    trip.notified = true
    trip.save!
  end

	def self.fare_cancelled_by_rider(fare)
		fare.driver.devices.each do |d|
				if(d.push_token.nil? || d.push_token == '')
					next	
				end
				n = PushHelper::push_message(d)
				n.alert = "Ride Cancelled!"
				n.data = { type: :fare_cancelled_by_rider, fare_id: fare.id }
				n.save!
				Rails.logger.debug "sending cancel push"
		end
	end

	def self.fare_cancelled_by_driver(fare)
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
