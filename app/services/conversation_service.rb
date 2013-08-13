class ConversationService
  def initialize(tweet)
    @tweet = tweet
  end

  # Finds or fetches the previous tweet from Twitter if tweet is a reply
  # Returns a tweet record
  def previous_tweet
    TweetFinder.new(@tweet.project, @tweet.previous_tweet_id).find_or_fetch if @tweet.reply?
  end

  # Finds or fetches the previous tweets from Twitter
  # Returns an array of previous tweets
  # Returns the cached tweets if already persisted in the database
  # otherwise fetches the tweets from Twitter
  def previous_tweets
    return [] unless @tweet.reply?
    @tweet.previous_tweets.presence || fetch_previous_tweets
  end

  private

  ##
  # Find or fetch previous tweets

  # Creates the conversation history for the given tweet
  # Returns an array of tweet records
  def fetch_previous_tweets
    return [] unless @tweet.reply?
    tweet = @tweet

    while tweet.previous_tweet
      begin
        @tweet.previous_tweets |= [tweet.previous_tweet]
      rescue ActiveRecord::RecordNotUnique
        # Record is already present, do nothing
      end

      tweet = tweet.previous_tweet
    end

    @tweet.previous_tweets
  end


end
