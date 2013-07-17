# ConversationWorker
#
# Finds or fetches the entire conversation of a tweet from Twitter
# Saves all previous tweets in the database
# Caches an array of previous tweet ids on the tweet
#
class ConversationWorker
  include Sidekiq::Worker
  sidekiq_options backtrace: true

  def perform(tweet_id)
    @tweet = Tweet.find(tweet_id)
    Conversation.new(@tweet).fetch_and_cache_conversation
  end
end
