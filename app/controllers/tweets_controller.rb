class TweetsController < TweetController
  skip_before_filter :load_tweet, only: :index

  def index
    @tweets = resolved_tweets_path? && project_tweets.resolved ||
      posted_tweets_path? && project_tweets.posted ||
      project_tweets.incoming

    @tweets &&= @tweets.decorate
  end

  def show
  end

  def resolve
    @tweet.resolve! && @tweet.create_event(:resolve, current_user)

    respond_to do |format|
      format.html { redirect_to incoming_project_tweets_path(@project),
        notice: 'Tweet has been resolved.' }
      format.js
    end
  end
end
