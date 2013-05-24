class TweetController < ProjectController
  before_filter :load_project_tweet

  private

  def load_project_tweet
    @tweet = project_tweet.decorate
  end

  def project_tweet
    @project.tweets.where(twitter_id: tweet_twitter_id).first!
  end

  def tweet_twitter_id
    user_session[:tweet_id] || params[:tweet_id] || params[:id]
  end
end
