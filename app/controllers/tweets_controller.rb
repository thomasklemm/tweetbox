class TweetsController < TweetController
  skip_before_filter :load_tweet, only: [:incoming, :stream, :resolved, :posted]

  ##
  # Collection actions

  def incoming
    @tweets = project_tweets.incoming.by_date(:desc).limit(20).decorate
  end

  alias_method :index, :incoming

  def stream
    @tweets = project_tweets.stream.by_date(:desc).page(params[:page]).per(25)
  end

  def posted
    @tweets = project_tweets.posted.by_date(:desc).limit(20).decorate
  end

  ##
  # Member actions

  def show
  end

  def resolve
    @tweet.resolve_by(current_user)
    push_reloaded_tweet

    respond_to do |format|
      format.html { redirect_to [@project, :tweets], notice: "Tweet has been resolved." }
      format.js   { render json: {} }
    end
  end

  def activate
    @tweet.activate!
    push_reloaded_tweet

    respond_to do |format|
      format.html { redirect_to [@project, @tweet], notice: "Tweet has been activated." }
      format.js   { render json: {} }
    end
  end

  private

  # Push tweet with reloaded state and events
  def push_reloaded_tweet
    TweetPusher.new(@tweet.reload).replace_tweet
  end
end
