class TweetsController < ProjectController
  def index
    case params[:workflow]
      when "open"
        @tweets = project_tweets.where(workflow_state: :open).limit(10)
      when "closed"
        @tweets = project_tweets.where(workflow_state: :closed).limit(10)
      else
        @tweets = project_tweets.where(workflow_state: :new).limit(10)
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
