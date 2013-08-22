class TweetPusher
  include ActionView::Helpers

  attr_reader :tweet

  def initialize(tweet)
    @tweet = tweet
  end

  # Replace all tweet nodes with the current representation
  def push_tweet
    Pusher.trigger(channel, 'replace-tweet', replace_tweet_data)
  end

  def stream_conversation
    # Don't push conversation tweets
    return true if tweet.conversation?

    prepend_conversation
    append_tweet_to_previous_conversations
  end

  private

  def channel
    "project-#{ tweet.project_id }"
  end

  def renderer
    Renderer.new.renderer
  end

  def replace_tweet_data
    { tag: "." + dom_id(tweet),
      tweet: renderer.render(tweet) }
  end

  def prepend_conversation
    # Create container
    data = { conversation: renderer.render(partial: 'tweets/conversation_for_tweet', locals: {tweet: tweet, include_tweets: false}) }
    Pusher.trigger(channel, 'prepend-conversation', data)

    # Append all tweets in conversation
    # and append new tweet to previous conversations
    tweet.full_conversation.each do |conversation_tweet|
      data = { tag: "#" + dom_id(tweet, :conversation_for),
               tweet: renderer.render(conversation_tweet) }
      Pusher.trigger(channel, 'append-tweet', data)
    end
  end

  def append_tweet_to_previous_conversations
    tweet.full_conversation.each do |conversation_tweet|
      # Avoid duplication
      next if tweet == conversation_tweet

      data = { tag: "#" + dom_id(conversation_tweet, :conversation_for),
               tweet: renderer.render(tweet) }

      Pusher.trigger(channel, 'append-tweet', data)
    end
  end
end
