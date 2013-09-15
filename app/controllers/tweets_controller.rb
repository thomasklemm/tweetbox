class TweetsController < TweetController
  skip_before_filter :load_tweet, only: [:index, :incoming, :stream, :posted]

  ##
  # Collection actions

  def incoming
    @tweets = project_tweets.incoming.
      by_date(:desc).max_id(params[:max_id]).limit(10)

    respond_to do |format|
      format.html
      format.js { render :stream }
    end
  end

  alias_method :index, :incoming

  def stream
    @tweets = project_tweets.stream.
      by_date(:desc).max_id(params[:max_id])

    # Return up to X tweets on an HTTP request, and un unlimited amount
    #   on an AJAX polling request
    if request.xhr?
      if params[:max_id]
        @tweets &&= @tweets.max_id(params[:max_id])
      elsif params[:min_id] != '' && params[:min_id] != 'undefined'
        @tweets &&= @tweets.min_id(params[:min_id])
      else
        # Request is malformed
        @tweets &&= @tweets.none
      end
    else
      @tweets &&= @tweets.limit(10)
    end
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
    @tweet.resolve!
    @tweet.reload and @tweet.push_replace_tweet

    # TODO: Move to background
    # track 'Tweet Resolve', @tweet, {
    #   'Resolution Time' => @tweet.resolution_time_in_seconds
    # }

    respond_to do |format|
      format.html { redirect_to [:incoming, @project, :tweets],
        notice: "Tweet has been resolved." }
      format.js
    end
  end

  def activate
    @tweet.activate!
    @tweet.reload and @tweet.push_replace_tweet

    respond_to do |format|
      format.html { redirect_to [@project, @tweet],
        notice: "Tweet has been activated." }
      format.js   { render :resolve }
    end
  end
end
