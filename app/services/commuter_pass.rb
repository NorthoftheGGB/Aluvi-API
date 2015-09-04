module CommuterPass

  def self.process_payment user, amount_cents

    begin
      payment = Payment.new
      payment.rider = user.as_rider
      payment.amount_cents = amount_cents
      payment.initiation = 'Balance Payment'
      if amount_cents > 10000
        amount_cents = 10000
      end
      payment.amount_cents = amount_cents

      customer = Stripe::Customer.retrieve(user.stripe_customer_id)
      charge = Stripe::Charge.create(
        :amount => payment.amount_cents,
        :currency => "usd",
        :customer => customer.id,
        :description => "Charge for Commuter Balance email: " + user.email + " id: " + user.id.to_s
      )
      if charge.paid == true
        payment.stripe_charge_status = 'Success'
        payment.captured_at = DateTime.now
        payment.paid = true

        user.commuter_balance_cents = user.commuter_balance_cents + amount_cents
        user.save
      else
        payment.stripe_charge_status = 'Failed'
      end
    rescue
      payment.stripe_charge_status = 'Error: ' + $!.message
      Rails.logger.debug $!.message
      Rails.logger.debug $!.backtrace.join("\n")
    ensure
      payment.save
    end

  end

  def self.process_payments
    User.where('commuter_balance_cents < -2000').each do |user|
      self.process_payment user, -user.commuter_balance_cents 
    end
  end

  def self.process_payout user, amount_cents
    begin
      payout = Payout.new
      payout.driver = user.as_driver
      payout.date = DateTime.now
 
      recipient = Stripe::Recipient.retrieve(user.stripe_recipient_id)

      if amount_cents > 20000
        amount_cents = 20000
      end
     payout.amount_cents = amount_cents

     transfer = Stripe::Transfer.create(
       :amount => amount_cents,
       :currency => "usd",
       :recipient => user.stripe_recipient_id,
       :destination => recipient.default_card, 
       :description => "Transfer for " + user.email,
       :statement_descriptor => "Aluvi Driver Payout"
     )
     payout.stripe_transfer_id = transfer.id

     user.commuter_balance_cents = user.commuter_balance_cents - amount_cents
     user.save

    rescue
      payout.stripe_transfer_status = 'Error: ' + $!.message
      Rails.logger.debug $!.message
      Rails.logger.debug $!.backtrace.join("\n")
    ensure
      payout.save
    end

  end

end
