class ConversationWorker
  include Sidekiq::Worker

  # Builds the complete conversation history for a tweet (given its primary key, not twitter_id)
  # Optionally takes the primary id of a twitter account to fetch the history with, defaults to
  # the twitter account that the tweet has been retrieved with.
  # Ensures that all previous tweets are fetched and stored in the database
  # Caches an array of previous tweet ids with the tweet itself for quick retrieval of the conversation history
  # Returns the tweet
  def perform(tweet_id, twitter_account_id=nil)
    # Only proceed if there is a history
    load_tweet(tweet_id)
    return unless tweet_is_a_reply?

    load_project
    load_twitter_account(twitter_account_id)

    fetch_previous_tweets_recursively
    cache_previous_tweet_ids

    @tweet
  end

  private

  def load_tweet(tweet_id)
    @tweet = Tweet.find(tweet_id)
  end

  def tweet_is_a_reply?
    @tweet.is_a_reply?
  end

  def load_project
    @project = @tweet.project
  end

  # Load given twitter account or the one that has been used to retrieve the tweet
  # Note that this falls back to picking a random project twitter account if the original one has been removed from our records
  def load_twitter_account(twitter_account_id)
    @twitter_account = twitter_account_id ? TwitterAccount.find(twitter_account_id) : @tweet.twitter_account
  end

  # Find or fetch the previous tweets recursively
  # Returns an array of the previous tweets sorted by their created_at timestamp
  def fetch_previous_tweets_recursively
    @previous_tweets = []
    tweet = @tweet

    while previous_tweet = find_or_fetch_previous_tweet(tweet)
      @previous_tweets << previous_tweet
      tweet = previous_tweet
    end

    @previous_tweets &&= @previous_tweets.compact.sort_by(&:created_at)
  end

  # Finds the previous tweet for the given one
  # or fetches it from Twitter
  # Returns a tweet record
  def find_or_fetch_previous_tweet(tweet)
    status_id = tweet.in_reply_to_status_id
    return unless status_id

    previous_tweet = @project.tweets.where(twitter_id: status_id).first
    previous_tweet.presence || fetch_tweet(status_id)
  end

  # Fetches the tweet with the given status id from Twitter
  # Returns a tweet record
  def fetch_tweet(status_id)
    status = @client.status(status_id)
    @project.create_tweet_from_twitter(status, state: :none, twitter_account: @twitter_account)

  # Retry on rate limit errors
  rescue Twitter::Error::TooManyRequests
    random_twitter_account = TwitterAccount.random
    perform(@tweet.id, random_twitter_account.id)

  # Sometimes a status gets deleted by the author
  rescue Twitter::Error::NotFound
    nil

  # Retry on all other errors
  rescue
    perform_in(5.minutes, @tweet.id)
  end

  # Cache previous tweet ids for the tweet
  def cache_previous_tweet_ids
    @tweet.previous_tweet_ids = @previous_tweets.map(&:twitter_id)
    @tweet.save!
  end
end
