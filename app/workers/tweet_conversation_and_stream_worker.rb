class TweetConversationAndStreamWorker
  include Sidekiq::Worker

  def perform(tweet_id)
    @tweet = Tweet.find(tweet_id)
    fetch_conversation
    push_conversation
  end

  private

  def fetch_conversation
    ConversationService.new(@tweet).previous_tweets if @tweet.reply?
  end

  def push_conversation
    TweetPusher.new(@tweet).stream_conversation
  end
end
