class TripController

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
		Rails.logger.debug(ride)
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

      PushHelper.send_notification rider do |notification|
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

	def self.cancel_trip trip

		ActiveRecord::Base.transaction do
			trip.aborted!
			trip.rides.each do |r|
				if r.state != 'cancelled'
					r.cancel_ride
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

 end
