Rails.logger.debug 'WARNING: stripe API credentials should be moved to environment variables'
Rails.configuration.stripe = {
	#:publishable_key => ENV['PUBLISHABLE_KEY'],
	#:secret_key      => ENV['SECRET_KEY']
	
	# these are testing keys
	:publishable_key => 'sk_test_biM5maZqf0SnHR2Eyfo7uy0X',
	:secret_key => 'sk_test_biM5maZqf0SnHR2Eyfo7uy0X'
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]

