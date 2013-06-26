Rack::Timeout.timeout = (ENV['TIMEOUT_IN_SECONDS'] || 20).to_i if defined? Rack::Timeout
