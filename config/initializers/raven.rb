require 'raven'

Raven.configure do |config|
    config.dsn = Rails.configuration.raven_dsn
end
