require 'active_record/associations/association_scope'

Sidekiq.configure_server do |config|
  database_url = ENV['DATABASE_URL']
  if(database_url)
    ENV['DATABASE_URL'] = "#{database_url}?pool=15"
    ActiveRecord::Base.establish_connection
  end
  # Via https://github.com/mperham/sidekiq/wiki/Advanced-Options
end
