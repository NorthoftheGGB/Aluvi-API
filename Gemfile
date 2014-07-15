source 'https://code.stripe.com'
source 'https://rubygems.org'

gem 'rails', '3.2.13'

# database
#gem 'mysql2'
gem 'foreigner', :git => 'git://github.com/deepwinter/foreigner.git'
gem 'pg'
gem 'activerecord-postgis-adapter', '~> 0.6.6'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# Non-blocking, single threaded server for concurrency
gem 'thin'

# Models that are state machines
gem 'aasm'

# Handle Money, Currencies, and Stripe API
gem 'money-rails'
gem 'monetize'
gem 'stripe'

# Geolocation
gem 'rgeo'
#gem 'rgeo-activerecord'
#gem 'activerecord-mysql2spatial-adapter'
gem 'mapquest'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
gem 'jbuilder'
gem 'grape-jbuilder'

# Google Cloud Messaging
gem 'gcm'

# Apple Push Notificatioins
gem 'rpush'

# Mapping
gem 'leaflet-rails'

# API
gem 'grape'

# Email
gem 'gmail_sender'

# File Storage
gem "paperclip", "~> 4.1"
gem 'aws-sdk', '~> 1.5.7'

# Documentation
gem 'grape-swagger'

# HTML
gem 'table_cloth'

# Testing
group :test do
	gem "factory_girl_rails", "~> 4.0"
	gem 'rspec'
	gem 'rspec-rails', '~> 3.0.0'
end

# To use debugger
# gem 'debugger'
