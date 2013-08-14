class TweetsController < TweetController
  skip_before_filter :load_tweet, only: [:incoming, :stream, :resolved, :posted]

  ##
  # Collection actions

  def incoming
    @tweets = @project.incoming_tweets.by_date(:desc).limit(20).decorate.shuffle
  end

  alias_method :index, :incoming

  def stream
    @tweets = @project.tweets.where(state: [:incoming, :resolved]).by_date(:desc).limit(20).decorate
  end

  def resolved
    @tweets = @project.resolved_tweets.by_date(:desc).limit(20).decorate
  end

  def posted
    @tweets = @project.posted_tweets.by_date(:desc).limit(20).decorate
  end

  ##
  # Member actions

  def show
  end

  def resolve
    @tweet.resolve_by(current_user)
    # Reload tweet's event counter cache
    @tweet.reload

    respond_to do |format|
      # TODO: Add link to tweet to flash message
      format.html { redirect_to [@project, :tweets], notice: 'Tweet has been resolved.' }
      format.js
    end
  end

  def activate
    @tweet.activate!
    redirect_to [@project, @tweet]
  end
end
