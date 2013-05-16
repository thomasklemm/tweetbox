class TweetsController < ProjectController
  before_filter :load_project_tweet, except: :index

  def index
    @tweets = case params[:flow].to_s
    when 'incoming' then project_tweets.incoming.limit(20)
    when 'answering' then project_tweets.answering.limit(10)
    when 'resolved' then project_tweets.resolved.limit(10)
    else return redirect_to project_tweets_path(@project, flow: :incoming)
    end
    @tweets &&= @tweets.decorate
  end

  def show
  end

  def mark_as_open
    @tweet.open!
    redirect_to action: :show
  end

  def mark_as_closed
    @tweet.close!
    redirect_to :back
  end

  private

  def project_tweets
    @project.tweets
  end

  def project_tweet
    @project.tweets.where(twitter_id: params[:id]).first!
  end

  def load_project_tweet
    @tweet = project_tweet.decorate
  end
end
