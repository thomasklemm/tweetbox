class TweetsController < ProjectController
  def index
    @tweets = if params[:flow].to_s == 'resolved'
      project_tweets.resolved.limit(10)
    else
      project_tweets.incoming
    end
  end

  def show
    @tweet = project_tweet
  end

  private

  def project_tweets
    @project.tweets
  end

  def project_tweet
    @project.tweets.find(params[:tweet_id] || user_session[:tweet_id] || params[:id])
  end
end
