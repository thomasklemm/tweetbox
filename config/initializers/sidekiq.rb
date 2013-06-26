# TODO: Remove on upgrading to Rails 4
require 'active_record/associations/association_scope'

Sidekiq.configure_server do |config|
  database_url = ENV['DATABASE_URL']
  if(database_url)
    ENV['DATABASE_URL'] = "#{database_url}?pool=10"
    ActiveRecord::Base.establish_connection
  end
end

# Source: https://github.com/mperham/sidekiq/wiki/Advanced-Options
