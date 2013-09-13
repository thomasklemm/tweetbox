web: bundle exec puma -p $PORT -C ./config/puma.rb
worker: bundle exec rerun --background --dir app,db,lib --pattern '{**/*.rb}' -- bundle exec sidekiq --verbose