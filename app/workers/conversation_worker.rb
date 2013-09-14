# ConversationWorker
#
# Finds or fetches the entire conversation of a tweet from Twitter
#   Saves all previous tweets in the database
#   Creates conversation join records for the given tweet
#
class ConversationWorker
  include Sidekiq::Worker
  sidekiq_options backtrace: true

  def perform(tweet_id)
    tweet = Tweet.find(tweet_id)
    ConversationService.new(tweet).previous_tweets

  # Don't retry on grave Twitter errors
  # REVIEW: SEE OTHER PLACES WHERE A TWITTER ERROR (ESP. FORBIDDEN) GETS RESCUED
  rescue Twitter::Error
    true
  end
end
