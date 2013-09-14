class TweetConversationAndStreamWorker
  include Sidekiq::Worker

  attr_reader :tweet

  def perform(tweet_id)
    @tweet = Tweet.find(tweet_id)
    fetch_conversation
    push_conversation
  end

  private

  def fetch_conversation
    ConversationService.new(tweet).previous_tweets if tweet.reply?
  end

  # Only push conversations to the client once
  def push_conversation
    tweet.reload and return if tweet.pushed?
    tweet.update(pushed: true)
    TweetPusher.new(@tweet).stream_conversation
  end
end
