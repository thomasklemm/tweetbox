class TweetPusher
  include ActionView::Helpers

  attr_reader :tweet

  def initialize(tweet)
    @tweet = tweet
  end

  def replace_tweet
    data = {
      tag: "." + dom_id(tweet),
      tweet: renderer.render(tweet)
    }

    Pusher.trigger(channel, 'replace-tweet', data)
  end

  private

  def channel
    "project-#{ tweet.project_id }"
  end

  def renderer
    @renderer ||= Renderer.new.renderer
  end
end
