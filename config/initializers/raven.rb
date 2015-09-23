require 'raven'

Raven.configure do |config|
    config.dsn = Rails.configuration.raven.dsn
end
