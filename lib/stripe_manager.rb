module StripeManager
	def self.set_driver_recipient_card(driver, token)

		Rails.logger.debug driver.full_name
		Rails.logger.debug token
		if driver.stripe_recipient_id.nil?
			recipient = Stripe::Recipient.create(
				:name => driver.full_name,
				:type => 'individual',
				:email => driver.email,
				:card => token
			)
			driver.stripe_recipient_id = recipient.id
		else
			recipient = Stripe::Recipient.retrieve(driver.stripe_recipient_id)
			recipient.card = token
			recipient.save
		end


		default_debit_card = recipient.cards.all().data[0]
		driver.recipient_card_brand = default_debit_card.brand	
		driver.recipient_card_exp_month = default_debit_card.exp_month
		driver.recipient_card_last4 = default_debit_card.last4
		driver.save
	end
end
