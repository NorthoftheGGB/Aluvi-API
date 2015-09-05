Rails.logger.debug 'WARNING: stripe API credentials should be moved to environment variables'
Rails.configuration.stripe = {
	#:publishable_key => ENV['PUBLISHABLE_KEY'],
	#:secret_key      => ENV['SECRET_KEY']
	
	# these are testing keys
	:publishable_key => 'pk_test_qebkNcGfOXsQJ6aSrimJt3mf',
	:secret_key => 'sk_test_P3DthPToFUqZMzmrnztHk9ju'
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]

