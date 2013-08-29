# Sentry exception tracking client
if Rails.env.production?
  require 'raven'

  Raven.configure(true) do |config|
    config.dsn = ENV['SENTRY_URL'] if ENV['SENTRY_URL']
    config.environments = %w[ production ]
  end
end
