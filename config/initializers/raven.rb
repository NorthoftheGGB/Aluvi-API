require 'raven'

if Rails.configuration.raven_dsn
  Raven.configure do |config|
    config.dsn = Rails.configuration.raven_dsn
  end
end
