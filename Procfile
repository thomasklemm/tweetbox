web: bundle exec puma -p $PORT -e $RACK_ENV -t 10:20
worker: bundle exec sidekiq -e production -c 7
clock: bundle exec clockwork lib/clock.rb
