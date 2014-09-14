class TripController

  # On Demand

  def self.driver_accepted_on_demand_fare(driver, fare)
      driver.offer_for_fare(fare).accepted!
      fare.accepted!(driver)
      driver.current_fare_id = fare.id
      driver.save

      # and send push messages to notify rider(s) that the fare has been found
      fare.riders.each do |rider|
        Rails.logger.debug "notifying rider"
        Rails.logger.debug rider
        ride = fare.rides.where(rider_id: rider.id).first
        rider.devices.each do |d|
          if(d.push_token.nil? || d.push_token == '')
            next
          end
          n = PushHelper::push_message(d)
          n.alert = "Ride Found!"
          n.data = { type: :fare_found, fare_id: fare.id, ride_id: ride.id,
                     request_type: ride.request_type,
                     meeting_point_place_name: fare.meeting_point_place_name,
                     drop_off_point_place_name: fare.drop_off_point_place_name }
          n.save!
        end
      end

      # send push messages to notify other drivers that the fare is closed
      self.send_offer_closed_messages fare
  end

  def self.send_offer_closed_messages fare

    fare.offers.offer_closed_delivered.each do |offer|
      self.send_notification offer.driver do |notification|
        n.alert = ""
        n.content_available = true
        n.data = { type: :offer_closed, offer_id: offer.id, fare_id: fare.id }
      end
    end

  end

  # Currently this notification is not used
  # This would be used to notify a driver of an assigned fare
  def self.driver_assigned(fare)
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



  # Commuter

  def self.request_commute_leg( departure_point, departure_place_name, destination_point, destination_place_name, pickup_time, driving, rider, trip_id)
    ride = CommuterRide.create(
        departure_point,
        departure_place_name,
        destination_point,
        destination_place_name,
        pickup_time,
        driving,
        rider
    )
    unless trip_id.nil?
      ride.trip_id = trip_id
    end
    ride.save
    ride.request!
    ride

  end


  def self.fare_completed(fare)

    # process the payment
    # TODO Refactor into delayed job
    fare.riders.where.not(id: fare.driver.id).each do |rider|
      begin
        ride = rider.rides.where( :fare_id => fare.id ).first

        payment = Payment.new
        payment.driver = fare.driver
        payment.fare = fare
        payment.rider = rider
        payment.ride = ride
        payment.amount_cents = ride.fixed_price
        payment.driver_earnings_cents = fare.fixed_earnings / fare.riders.count
        payment.stripe_customer_id = rider.stripe_customer_id

        case ride.request_type
          when 'on_demand'
          when 'commuter'

            payment.initiation = 'Standard Payment'
						if payment.amount_cents > 1200
							payment.amount_cents = 1200
						end

            customer = Stripe::Customer.retrieve(rider.stripe_customer_id)
            charge = Stripe::Charge.create(
                :amount => payment.amount_cents,
                :currency => "usd",
                :customer => customer.id,
                :description => "Charge for Voco Fare: " + fare.id.to_s
            )
            if charge.paid == true
              payment.stripe_charge_status = 'Success'
              payment.captured_at = DateTime.now
              payment.paid = true
            else
              payment.stripe_charge_status = 'Failed'
            end

          when 'commuter_card' # Currently Unused

            payment.initiation = 'Commuter Card'

            # refill commuter card if necessary
            tries = 0
            begin
              if rider.commuter_balance_cents < ride.cost_per_rider
                # fill the commuter card
                if rider.commuter_refill_amount_cents <= 0
                  raise "Commuter refill not set"
                end

                paid = PaymentsHelper.autofill_commuter_card rider
                if paid == true
                  raise "retry"
                else
                  raise "Failed to refill commuter card"
                end
              end
            rescue
              if $!.to_s == 'retry'
                Rails.logger.debug 'rescuing for retry'
                tries += 1
                if tries > 2
                  raise "Commuter card refill did not reach required amount after 2 iterations"
                end
                retry
              else
                raise $!
              end
            end

            # pay via commuter card
            payment.stripe_charge_status = 'Paid By Commuter Card'
            payment.paid = true
            rider.commuter_balance_cents -= payment.amount_cents
            rider.save

        end

      rescue
        payment.stripe_charge_status = 'Error: ' + $!.message
        Rails.logger.debug $!.message
        Rails.logger.debug $!.backtrace.join("\n")
      ensure
        payment.save
      end

      send_notification rider do |notification|
        if payment.paid == true
          notification.alert = "Receipt For Your Ride"
          notification.data = { type: :ride_receipt, fare_id: fare.id, amount: payment.amount_cents }
        else
          notification.alert = "Problem Processing Payment For Your Ride"
          notification.data = { type: :ride_payment_problem, fare_id: fare.id, amount: payment.amount_cents }
        end
      end

    end

    fare.arrived!

    fare.driver.current_fare = nil
    fare.driver.save

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
    send_trip_notification trip do |notification|
      notification.alert = "We were unable to fulfill your commute to and from work.  Please try again tomorrow"
      notification.data = { type: :trip_unfulfilled, trip_id: trip.id }
    end
  end

  def self.send_trip_notification trip
    send_notification trip.rides[0].rider do |notification|
      yield notification
    end
    trip.notified = true
    trip.save!
  end

  #TODO move this to PushHelper
  def self.send_notification user
    user.devices.each do |d|
      if(d.push_token.nil? || d.push_token == '')
        next
      end
      notification = PushHelper::push_message(d)
      yield notification
      notification.save!
    end
  end
end
