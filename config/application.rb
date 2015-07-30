require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  Bundler.require(:default, Rails.env)
end

module Voco
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
		config.time_zone = 'Pacific Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

		# Opt into new tranactional callback error raise behavior
		config.active_record.raise_in_transactional_callbacks = true

		# Activate observers that should always be running
		config.active_record.observers = [:ride_observer, :fare_observer, :driver_observer]

		config.autoload_paths += Dir[Rails.root.join('app', 'views', 'api', '**/')]
		config.autoload_paths += Dir[Rails.root.join('app', 'models', '**/')]
		config.autoload_paths += Dir[Rails.root.join('app', 'api', '**/')]
		config.autoload_paths << Rails.root.join('lib')

		# AWS - Paperclip
		config.paperclip_defaults = {
			  :storage => :s3,
			  :s3_credentials => {
					:access_key_id => "AKIAIYBNFGUMCVPBP5VQ",
					:secret_access_key => "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"
			  }
		}

		config.middleware.use(Rack::Config) do |env|
			env['api.tilt.root'] = Rails.root.join 'app', 'views', 'api'
		end

		# scheduler
		config.commute_scheduler = {
			:threshold_from_driver_origin => 3200, # 2 mile
			:threshold_from_driver_destination => 400, # 1/4 mile
			:morning_start_hour => 7,
			:morning_stop_hour => 9,
			:evening_start_hour => 4 + 12,
			:evening_stop_hour => 7 + 12
		}
  end
end
