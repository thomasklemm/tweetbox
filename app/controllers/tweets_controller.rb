class TweetsController < TweetController
  skip_before_filter :load_tweet, only: [:incoming, :stream, :resolved, :posted]

  ##
  # Collection actions

  def incoming
    @tweets = project_tweets.incoming.by_date(:desc).limit(20).decorate
  end

  alias_method :index, :incoming

  def stream
    @tweets = project_tweets.stream.by_date(:desc).limit(20).decorate
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

    # Reload tweet state and events
    @tweet.reload

    data = {
      tag: "." + dom_id(@tweet),
      tweet: render_to_string(partial: 'tweet', locals: {tweet: @tweet})
    }

    Pusher.trigger('channel', 'update-tweet', data)

    render json: {success: true}

    # respond_to do |format|
    #   # TODO: Add link to tweet to flash message
    #   format.html { redirect_to [@project, :tweets], notice: 'Tweet has been resolved.' }
    #   format.js do
    #     # Reload tweet's event counter cache
    #     @tweets = [@tweet.reload]
    #     @tweets |= @tweet.previous_tweets if @tweet.previous_tweets.size > 0
    #     @tweets |= @tweet.future_tweets if @tweet.future_tweets.size > 0

    #     string = render_to_string(partial: 'conversation_for_tweet', tweet: @tweets.first)
    #     raise string.inspect

    #     data = {
    #       render partial: 'conversation_for_tweet', tweet: @tweet
    #     }.to_json

    #     # replace all conversation_for_tweet containers in which the tweet is included
    #     @tweets.each do |tweet|
    #       Pusher.trigger('channel', 'update-tweet', { dom_id: ('#' + dom_id(tweet, :conversation_for)), tweet: render_to_string(partial: 'conversation_for_tweet', tweet: tweet) })
    #     end
    #   end
    # end
  end

  def activate
    @tweet.activate!
    # TODO: Really do this via ajax if nescessary at all
    redirect_to [@project, @tweet]
  end
end
