module PaymentsHelper

	def self.autofill_commuter_pass( user )
		self.fill_commuter_pass( user, user.commuter_refill_amount_cents )
	end

	def self.fill_commuter_pass ( user, amount_cents )

		customer = Stripe::Customer.retrieve(user.stripe_customer_id)
		charge = Stripe::Charge.create(
			:amount => user.commuter_refill_amount_cents,
			:currency => "usd",
			:customer => customer.id,
			:description => "Refill for Voco Commuter Card"
		)

		refill_payment = Payment.new
		refill_payment.initiation = 'Commuter Refill'
		refill_payment.rider = user
		refill_payment.stripe_charge_status = 'Success'
		refill_payment.captured_at = DateTime.now
		refill_payment.stripe_customer_id = user.stripe_customer_id
		refill_payment.amount_cents = user.commuter_refill_amount_cents
		refill_payment.save

		user.commuter_balance_cents += user.commuter_refill_amount_cents
		user.save

		true

	end

end
