class TweetsController < TweetController
  skip_before_filter :load_tweet, only: [:index, :incoming, :stream, :posted, :next_page, :poll]

  ##
  # Collection actions

  def incoming
    @tweets = project_tweets.incoming.
      by_date(:desc).limit(10)
  end
  alias_method :index, :incoming

  def stream
    @tweets = project_tweets.stream.
      by_date(:desc).limit(10)
  end

  # Returns the next page of tweets in an AJAX request
  def next_page
    @tweets = project_tweets.by_date(:desc).limit(15)

    @tweets = params[:flow] == 'incoming' ? @tweets.incoming : @tweets.stream

    if params[:max_id] != '' && params[:max_id] != 'undefined'
      @tweets = @tweets.max_id(params[:max_id])
    else
      # Request is malformed
      raise 'Required request param max_id is malformed.'
    end
  end

  # Return an un unlimited amount of tweets on an AJAX polling request
  def poll
    @tweets = project_tweets.by_date(:desc)

    @tweets = params[:flow] == 'incoming' ? @tweets.incoming : @tweets.stream

    if params[:min_id] != '' && params[:min_id] != 'undefined'
      @tweets = @tweets.min_id(params[:min_id])
    else
      # Request is malformed
      raise 'Required request param min_id is malformed.'
    end
  end

  def posted
    @tweets = project_tweets.posted.by_date(:desc).
      page(params[:page]).per(30)
  end

  ##
  # Member actions

  def show
  end

  def resolve
    @tweet.resolve!
    @tweet.reload and @tweet.push_replace_tweet

    track 'Tweet Resolve', @tweet, {
      'Resolution Time' => @tweet.resolution_time_in_seconds
    }

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
