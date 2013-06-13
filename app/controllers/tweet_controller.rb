class TweetController < ProjectController
  before_filter :load_tweet

  private

  def load_tweet
    @tweet ||= project_tweet.decorate
  end

  def project_tweets
    @project.tweets
  end

  def project_tweet
    project_tweets.where(twitter_id: tweet_twitter_id).first!
  end

  def tweet_twitter_id
    params[:tweet_id] || params[:id]
  end
end
