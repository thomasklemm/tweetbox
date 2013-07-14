# Conversationalist
#
# Finds or fetches the entire conversation of a tweet from Twitter
# Saves all previous tweets in the database
# Caches an array of previous tweet ids on the tweet
#
class Conversationalist
  include Sidekiq::Worker

  def perform(tweet_id)
    @tweet = Tweet.find(tweet_id)
    @tweet.fetch_previous_tweets_and_cache_ids
  end
end
