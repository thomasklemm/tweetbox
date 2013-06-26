# Sentry exception tracking client
if Rails.env.production?
  require 'raven'

  Raven.configure do |config|
    config.dsn = ENV['SENTRY_URL']
    config.environments = %w[ production ]
  end
end
