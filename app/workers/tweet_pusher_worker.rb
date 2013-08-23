class TweetPusherWorker
  include Sidekiq::Worker

  def perform(tweet_id)
    tweet = Tweet.find(tweet_id)
    TweetPusher.new(tweet).push_tweet
  end
end
