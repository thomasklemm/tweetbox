Rack::Timeout.timeout = (ENV['TIMEOUT_IN_SECONDS'] || 20).to_i unless (Rails.env.development? || Rails.env.test?)
