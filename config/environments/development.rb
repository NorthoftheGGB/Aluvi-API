Voco::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  config.log_level = :debug

	config.eager_load  = false

	config.paperclip_defaults = {
		:s3_credentials => {
			:bucket => 'aluvi-development',
			:access_key_id => 'AKIAIZ6VCH3PVEUGHYVA',
			:secret_access_key => '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'
		}
	}

  config.stripe = {
    :publishable_key => 'pk_test_qebkNcGfOXsQJ6aSrimJt3mf',
    :secret_key => 'sk_test_P3DthPToFUqZMzmrnztHk9ju'
  }

  config.raven.dsn = 'https://5ab8495b1d14474cb27678386f05a544:014bc0f112474fbd89639b41b85f26f5@app.getsentry.com/53130'

end
