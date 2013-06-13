class TweetsController < TweetController
  skip_before_filter :load_project_tweet, only: :index

  def index
    @tweets = if incoming_tweets?
      project_tweets.incoming
    elsif open_tweets?
      project_tweets.in_progress
    elsif closed_tweets?
      project_tweets.closed
    else
      project_tweets.incoming
    end

    @tweets &&= @tweets.decorate
  end

  def show
  end

  def appreciate
    @tweet.close!
    @tweet.create_event(:appreciate, current_user)
    redirect_to incoming_project_tweets_path(@project), notice: 'Tweet has been appreciated.'
  end

  def open_case
    @tweet.open!
    @tweet.create_event(:open_case, current_user)
    redirect_to project_tweet_path(@project, @tweet), notice: 'Case has been opened.'
  end

  def resolve
    @tweet.close!
    @tweet.create_event(:resolve, current_user)
    redirect_to incoming_project_tweets_path(@project), notice: 'Case has been resolved.'
  end

  private

  def project_tweets
    @project.tweets
  end

  ##
  # Path matchers

  def incoming_tweets?
    request.path == incoming_project_tweets_path(@project)
  end

  def open_tweets?
    request.path == open_project_tweets_path(@project)
  end

  def closed_tweets?
    request.path == resolved_project_tweets_path(@project)
  end
end
