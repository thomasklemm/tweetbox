web: bundle exec puma -p $PORT -e $RACK_ENV -t 3:10
worker: bundle exec sidekiq -e production -c 5
