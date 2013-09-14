class TweetsController < TweetController
  skip_before_filter :load_tweet, only: [:incoming, :stream, :resolved, :posted]

  ##
  # Collection actions

  def incoming
    @tweets = project_tweets.incoming.
      by_date(:desc).max_id(params[:max_id]).limit(50)
  end

  alias_method :index, :incoming

  def stream
    @tweets = project_tweets.stream.
      by_date(:desc).max_id(params[:max_id]).min_id(params[:min_id])
    # Return up to X tweets on an HTTP request, and un unlimited amount
    #   on an AJAX polling request
    @tweets.limit(50) unless request.xhr?
  end

  def posted
    @tweets = project_tweets.posted.
      by_date(:desc).page(params[:page]).per(30)
  end

  ##
  # Member actions

  def show
  end

  def resolve
    @tweet.resolve_by(current_user)
    @tweet.reload
    @tweet.push

    track 'Tweet Resolve', @tweet, {
      'Resolution Time' => @tweet.resolution_time
    }

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
