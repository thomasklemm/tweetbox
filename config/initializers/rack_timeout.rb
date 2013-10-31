Rack::Timeout.timeout = (ENV['TIMEOUT_IN_SECONDS'] || 28).to_i if defined? Rack::Timeout
