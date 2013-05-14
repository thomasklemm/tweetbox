class TweetsController < ProjectController
  def index
    @tweets = case params[:flow].to_s
    when 'incoming' then project_tweets.incoming.limit(10)
    when 'answering' then project_tweets.answering.limit(10)
    when 'resolved' then project_tweets.resolved.limit(10)
    else return redirect_to project_tweets_path(@project, flow: :incoming)
    end
  end

  def show
    @tweet = project_tweet
  end

  def update
    @tweet = project_tweet

    case params[:event].to_s
    when 'open' then @tweet.open!
    when 'close' then @tweet.close!
    end

    redirect_to :back
  end

  private

  def project_tweets
    @project.tweets
  end

  def project_tweet
    @project.tweets.where(twitter_id: params[:id]).first!
  end
end
