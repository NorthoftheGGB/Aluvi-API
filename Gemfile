source 'https://rubygems.org'

gem 'rails', '4.2.2'
gem 'actionview'

# javascript runtime
gem 'execjs'
gem 'therubyracer'

# rails features
gem 'protected_attributes'
gem 'rails-observers'

# database
gem 'mysql2', '~> 0.3.18' 
gem 'foreigner', :git => 'git://github.com/deepwinter/foreigner.git'
gem 'pg'
gem 'activerecord-postgis-adapter'

#web

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

gem 'jquery-rails'

# Non-blocking, single threaded server for concurrency
gem 'thin'

# Models that are state machines
gem 'aasm'

# Handle Money, Currencies, and Stripe API
gem 'stripe', ">= 1.21", :source => 'https://code.stripe.com'
# Geolocation
gem 'rgeo'
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
gem 'aws-sdk', '~> 1.6'

# Documentation
gem 'grape-swagger'

# HTML
gem 'table_cloth'

# Jobs
gem 'resque'
gem 'resque-scheduler'

# QA
gem 'multi_logger'
gem "sentry-raven", :git => "https://github.com/getsentry/raven-ruby.git"


# MemCache
gem 'dalli'
gem 'memcachier'

# Deployment
gem 'capistrano'


# Testing
group :test do
	gem "factory_girl_rails", "~> 4.0"
	gem 'rspec'
	gem 'rspec-rails', '~> 3.1'
  gem 'database_cleaner'
	gem 'stripe-ruby-mock', '~> 2.1.1', :require => 'stripe_mock', :git => 'https://github.com/kathyonu/stripe-ruby-mock.git', :branch => 'stripe-1.24.0'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
end

gem "spring", group: :development
gem "spring-commands-rspec", group: :development

