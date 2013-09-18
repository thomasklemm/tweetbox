# TODO: REWORK AFTER RAILS4 UPGRADE
require 'sidekiq/web'

Sidekiq.configure_server do |config|

  # ActiveRecord connection pool size
  database_url = ENV['DATABASE_URL']
  if(database_url)
    ENV['DATABASE_URL'] = "#{database_url}?pool=10"
    ActiveRecord::Base.establish_connection
  end

  # Poll interval for scheduled jobs in seconds
  config.poll_interval = 1
end

# # HTTP Basic authentication for the Sidekiq Web Interface
# Sidekiq::Web.use Rack::Auth::Basic do |username, password|
#   username == 'tweetbox' && password == 'dash'
# end

# Source: https://github.com/mperham/sidekiq/wiki/Advanced-Options
