# ConversationWorker
#
# Finds or fetches the entire conversation of a tweet from Twitter
# Saves all previous tweets in the database
# Creates conversation join records for the given tweet
#
class ConversationWorker
  include Sidekiq::Worker
  sidekiq_options backtrace: true

  def perform(tweet_id)
    @tweet = Tweet.find(tweet_id)
    ConversationService.new(@tweet).previous_tweets
  end
end
