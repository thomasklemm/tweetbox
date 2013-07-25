# TODO: REWORK AFTER RAILS4 UPGRADE
# TODO: Remove on upgrading to Rails 4
require 'active_record/associations/association_scope'
require 'sidekiq/web'

Sidekiq.configure_server do |config|

  # ActiveRecord connection pool size
  database_url = ENV['DATABASE_URL']
  if(database_url)
    ENV['DATABASE_URL'] = "#{database_url}?pool=10"
    ActiveRecord::Base.establish_connection
  end

  # Poll interval for scheduled jobs in seconds
  config.poll_interval = 5
end

# HTTP Basic authentication for the Sidekiq Web Interface
Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  username == 'tweetbox' && password == 'dash'
end

# Source: https://github.com/mperham/sidekiq/wiki/Advanced-Options
