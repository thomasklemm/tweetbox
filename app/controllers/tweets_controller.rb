class TweetsController < TweetController
  skip_before_filter :load_tweet, only: [:incoming, :resolved, :posted]

  ##
  # Collection actions

  def incoming
    @tweets = project_tweets.incoming.limit(100).decorate
  end

  alias_method :index, :incoming

  def resolved
    @tweets = project_tweets.resolved.limit(100).decorate
  end

  def posted
    @tweets = project_tweets.posted.limit(100).decorate
  end

  ##
  # Member actions

  def show
  end

  def resolve
    @tweet.resolve_and_record!(current_user)

    respond_to do |format|
      format.html { redirect_to [@project, :tweets], notice: 'Tweet has been resolved.' }
      format.js
    end
  end

  def activate
    @tweet.activate!
    redirect_to [@project, @tweet]
  end
end
