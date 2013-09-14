# TweetPusherWorker
#
# Replaces all instances of the given tweet on the page
#   (in one or many conversations)
#   with an updated rendering of the same tweet
#
class TweetPusherWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, backtrace: true

  def perform(tweet_id)
    tweet = Tweet.find(tweet_id)
    TweetPusher.new(tweet).push_replace_tweet

  # Don't retry on Pusher errors (like quota exceeded)
  rescue Pusher::Error
    true
  end
end
