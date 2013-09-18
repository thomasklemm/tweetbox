require 'sidekiq/web'

Sidekiq.configure_server do |config|
  # ActiveRecord connection pool size
  database_url = ENV['DATABASE_URL']
  if(database_url)
    ENV['DATABASE_URL'] = "#{database_url}?pool=10"
    ActiveRecord::Base.establish_connection
  end

  # Poll interval for scheduled jobs in seconds (default is 15)
  config.poll_interval = 5
end

# Source: https://github.com/mperham/sidekiq/wiki/Advanced-Options
