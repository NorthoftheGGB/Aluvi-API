  payment = Payment.new
        payment.driver = fare.driver
        payment.fare = fare
        payment.rider = rider
        payment.ride = ride
        payment.amount_cents = ride.fixed_price
        payment.driver_earnings_cents = fare.fixed_earnings / fare.riders.count
        payment.stripe_customer_id = rider.stripe_customer_id

        case ride.request_type
          when 'no_longer_used'

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


