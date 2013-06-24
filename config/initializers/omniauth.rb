# Middleware
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, ENV['TWITTER_CONSUMER_KEY'], ENV['TWITTER_CONSUMER_SECRET']
end

# Logging
OmniAuth.config.logger = Rails.logger

# Enable OmniAuth test mode
Rails.env.test? and OmniAuth.config.test_mode = true
