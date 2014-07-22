module PaymentsHelper

	def self.autofill_commuter_pass( user )
		self.fill_commuter_pass( user, user.commuter_refill_amount_cents )
	end

	def self.fill_commuter_pass ( user, amount_cents )

		ActiveRecord::Base.transaction do

			# update database first, so exception will trigger rollback 
			fill_payment = Payment.new
			fill_payment.initiation = 'Commuter Refill'
			fill_payment.rider = user
			fill_payment.stripe_charge_status = 'Success'
			fill_payment.captured_at = DateTime.now
			fill_payment.stripe_customer_id = user.stripe_customer_id
			fill_payment.amount_cents = amount_cents
			fill_payment.save

			user.commuter_balance_cents += amount_cents
			user.save

			customer = Stripe::Customer.retrieve(user.stripe_customer_id)
			charge = Stripe::Charge.create(
				:amount => amount_cents,
				:currency => "usd",
				:customer => customer.id,
				:description => "Refill for Voco Commuter Card"
			)

			true
		end

	end

end
