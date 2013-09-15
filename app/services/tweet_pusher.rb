# TweetPusher
#
# Push replaces instances of a tweet in the browser
#   with an updated rendering
#
class TweetPusher
  include ActionView::Helpers

  def initialize(tweet)
    @tweet = tweet
  end
  attr_reader :tweet

  # Replace all tweet nodes (might be more than one)
  # with an updated rendering
  def push_replace_tweet
    Pusher.trigger(project_channel, 'replace-tweet', data)
  end

  private

  def project_channel
    "project-#{ tweet.project_id }"
  end

  def data
    { tag: "." + dom_id(tweet),
      tweet: Renderer.new.render(tweet) }
  end
end
