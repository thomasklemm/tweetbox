class TweetsController < TweetController
  skip_before_filter :load_tweet, only: [:incoming, :stream, :resolved, :posted]

  ##
  # Collection actions

  def incoming
    @tweets = project_tweets.incoming.by_date(:desc).page(params[:page]).per(25)
    respond_to do |format|
      format.html
      format.js { render :stream }
    end
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
    @tweet.reload
    @tweet.push

    respond_to do |format|
      format.html { redirect_to [@project, :tweets], notice: "Tweet has been resolved." }
      format.js
    end
  end

  def activate
    @tweet.activate!
    @tweet.reload
    @tweet.push

    respond_to do |format|
      format.html { redirect_to [@project, @tweet], notice: "Tweet has been activated." }
      format.js   { render json: {} }
    end
  end
end
