class Conversation
  def initialize(tweet)
    @tweet = tweet
  end

  # Finds or fetches the previous tweet from Twitter if tweet is a reply
  # Returns a tweet record
  def previous_tweet
    find_or_fetch_tweet(@tweet.previous_tweet_id) if @tweet.reply?
  end

  # Finds or fetches the previous tweets from Twitter
  # Returns an array of tweet records
  def previous_tweets
    @previous_tweets ||= begin
      return unless @tweet.reply?

      tweet = @tweet
      tweets = []

      while tweet.previous_tweet
        tweets << tweet.previous_tweet
        tweet = tweet.previous_tweet
      end

      tweets.compact.sort_by(&:created_at)
    end
  end

  # Finds or fetches the previous tweets from Twitter
  # Caches previous tweet ids on the tweet
  # Returns true
  def fetch_and_cache_conversation
    # Find or fetch previous tweets
    return unless @tweet.reply?
    return unless previous_tweets

    # Cache previous tweet ids
    @tweet.previous_tweet_ids = previous_tweets.map(&:twitter_id)
    @tweet.save!
  end

  private

  ##
  # Find or fetch a tweet

  # Returns a tweet record
  def find_or_fetch_tweet(twitter_id)
    find_tweet(twitter_id) || fetch_tweet(twitter_id)
  end

  # Returns the tweet record from the database if present
  def find_tweet(twitter_id)
    @tweet.project.tweets.where(twitter_id: twitter_id).first
  end

  # Fetches the given status from Twitter
  # Returns the persisted tweet record
  def fetch_tweet(twitter_id)
    status = TwitterAccount.random.client.status(twitter_id)

    # Avoid referencing random twitter account
    tweet = TweetMaker.from_twitter(status, project: @tweet.project, state: :conversation)

  rescue Twitter::Error => e
    @runs ||= 0 and @runs += 1

    # Statuses may be deleted voluntarily by the author
    if e.is_a? Twitter::Error::NotFound
      return nil if @runs > 2
    else
      raise e if @runs > 3
    end

    # Retry using a different random Twitter account
    sleep 1 and retry
  end
end
