class TwitterWorker
  include Sidekiq::Worker

  def perform(type, twitter_account_id, term=nil)
    @twitter_account = TwitterAccount.find(twitter_account_id)
    @project = @twitter_account.project
    @client = @twitter_account.client

    case type.to_s
    when 'mentions' then get_mentions
    when 'home' then get_home
    when 'search' then get_search(term)
    else raise "TwitterWorker: Please pass a valid type (Did not recognize #{type.to_s})"
    end
  end

  # Schedule mentions queries for all active accounts
  # to be performed asynchronously
  def self.schedule_mentions
    twitter_account_ids = TwitterAccount.where(get_mentions: true).pluck(:id)

    twitter_account_ids.each do |twitter_account_id|
      TwitterWorker.perform_async(:mentions, twitter_account_id)
    end
  end

  # Schedule home timeline queries for all active accounts
  # to be performed asynchronously
  def self.schedule_homes
    twitter_account_ids = TwitterAccount.where(get_home: true).pluck(:id)

    twitter_account_ids.each do |twitter_account_id|
      TwitterWorker.perform_async(:home, twitter_account_id)
    end
  end

  # Schedule searches for specific terms to be performed asynchronously
  def self.schedule_searches
    # How would a Search model look like?
  end

  private

  def get_mentions
    options = { count: 200 }
    options[:since_id] = @twitter_account.max_mentions_tweet_id if @twitter_account.max_mentions_tweet_id

    statuses = @client.mentions_timeline(options)
    tweets = @project.create_tweets_from_twitter(statuses, state: :new)

    # Set new max mentions tweet id to include in the next run
    @project.update_column(:max_mentions_tweet_id, tweets.map(&:twitter_id).max)
  end

  def get_home
    options = { count: 200 }
    options[:since_id] = @twitter_account.max_home_tweet_id if @twitter_account.max_home_tweet_id

    statuses = @client.home_timeline(options)
    tweets = @project.create_tweets_from_twitter(statuses, state: :none)

    # Set new max home tweet id to include in the next run
    @project.update_column(:max_home_tweet_id, tweets.map(&:twitter_id).max)
  end

  def get_search(term)
    # tweets = @client.x
    # how should we cache the current max tweet id?
  end
end
