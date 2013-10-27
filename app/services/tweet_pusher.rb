# TweetPusher
#
# Push replaces instances of a tweet in the browser
#   with an updated rendering
#
class TweetPusher
  include ActionView::Helpers
  include TweetEventHelper

  def initialize(tweet)
    @tweet = tweet
  end
  attr_reader :tweet

  # Replace all tweet nodes (might be more than one)
  # with an updated rendering
  def push_replace_tweet
    Pusher.trigger(project_channel, 'replace-tweet', tweet_data)
  end

  def push_append_tweet_event(user_full_name, timestamp)
    Pusher.trigger(project_channel, 'append-tweet-event', tweet_event_data(user_full_name, timestamp))
  end

  private

  def project_channel
    "project-#{ tweet.project_id }"
  end

  def tweet_data
    { tag: ".#{ dom_id(tweet)}",
      tweet: Renderer.new.render(tweet) }
  end

  def tweet_event_data(user_full_name, timestamp)
    {
      tag: ".#{ dom_id(tweet)} .events",
      event: render_tweet_event(user_full_name, timestamp)
    }
  end
end
