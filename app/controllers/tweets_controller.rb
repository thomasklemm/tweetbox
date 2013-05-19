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
    redirect_to project_tweet_path(@project, @tweet), notice: 'Tweet has been marked as open.'
  end

  def mark_as_closed
    @tweet.close!
    redirect_to project_tweets_path(@project, flow: :incoming)
    # NOTE: Adding a flash seems to stick around until really rendered,
    #       even in a future action if the current one is via AJAX
  end
end
