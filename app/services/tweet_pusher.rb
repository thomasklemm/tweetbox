class TweetPusher
  include ActionView::Helpers

  attr_reader :tweet

  def initialize(tweet)
    @tweet = tweet
  end

  # Replace the existing tweet (within one or many conversations)
  # with the newly rendered dom node
  def replace_tweet
    data = {
      tag: "." + dom_id(tweet),
      tweet: renderer.render(tweet)
    }

    puts data.size

    Pusher.trigger(channel, 'replace-tweet', data)
  end

  # Prepend the conversation for a tweet
  # on the incoming and stream views
  def prepend_conversation
    data = {
      conversation: renderer.render(partial: 'tweets/conversation_for_tweet', locals: {tweet: tweet})
    }

    Pusher.trigger(channel, 'prepend-conversation', data)
  end

  private

  def channel
    "project-#{ tweet.project_id }"
  end

  def renderer
    @renderer ||= Renderer.new.renderer
  end
end
