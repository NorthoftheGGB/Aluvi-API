Rails.logger.debug 'WARNING: stripe API credentials should be moved to environment variables'


Stripe.api_key = Rails.configuration.stripe[:secret_key]

