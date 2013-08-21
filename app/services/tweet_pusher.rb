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

    Pusher.trigger(channel, 'replace-tweet', data)
  end

  def

  # Prepend the conversation container for a tweet
  # on the incoming and stream views
  def prepend_conversation_container
    data = {
      conversation_container: renderer.render(inline: "<%= div_for tweet, :conversation_for %>")
    }

    Pusher.trigger(channel, 'prepend-conversation-container', data)
  end

  # Appends a tweet to a given conversation
  def append_tweet
    tweet.unordered_conversation.each do |t|
      data = {
        tag: '#' + dom_id(t, :conversation_for),
        tweet: renderer.render(tweet)
      }

      Pusher.trigger(channel, 'append-tweet', data)
    end
  end

  private

  def channel
    "project-#{ tweet.project_id }"
  end

  def renderer
    @renderer ||= Renderer.new.renderer
  end
end
