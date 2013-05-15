class TwitterWorker
  include Sidekiq::Worker

  # Options / arguments:
  #   - type: Required type of the query to be performed, should be in [:mentions, :home, :search]
  #   - twitter_account_id: Required for mentions and home timeline queries
  #   - search_id: Required for search queries
  def perform(type, twitter_account_or_search_id)
    type &&= type.to_s

    # Raise unless type is whitelisted
    raise StandardError, "TwitterWorker: #{type} is not a valid type." unless %w(mentions home search).include?(type)

    # Delegate to the matching type action
    case type
    when 'mentions' then get_mentions(twitter_account_or_search_id)
    when 'home' then get_home(twitter_account_or_search_id)
    when 'search' then get_search(twitter_account_or_search_id)
    end

  rescue Twitter::Error::TooManyRequests
    puts "TwitterWorker: Caught Twitter::Error::TooManyRequests error for #{ type }, #{ twitter_account_or_search_id }"
    false
  end

  # Schedule mentions queries for all active accounts
  # to be performed asynchronously
  def self.schedule_mentions
    TwitterAccount.where(get_mentions: true).each do |twitter_account|
      TwitterWorker.perform_async(:mentions, twitter_account.id)
    end
  end

  # Schedule home timeline queries for all active accounts
  # to be performed asynchronously
  def self.schedule_homes
    TwitterAccount.where(get_home: true).each do |twitter_account|
      TwitterWorker.perform_async(:home, twitter_account.id)
    end
  end

  # Schedule searches for specific terms to be performed asynchronously
  def self.schedule_searches
    Search.where(active: true).each do |search|
      TwitterWorker.perform_async(:search, search.id)
    end
  end

  private

  ##
  # Mentions and home

  def get_mentions(twitter_account_id)
    load_twitter_account(twitter_account_id)

    statuses = @client.mentions_timeline(mentions_options)
    tweets = @project.create_tweets_from_twitter(statuses, state: :new, twitter_account: @twitter_account)

    @twitter_account.update_stats!(:mentions, tweets.map(&:twitter_id).max)
  end

  def get_home(twitter_account_id)
    load_twitter_account(twitter_account_id)

    statuses = @client.home_timeline(home_options)
    tweets = @project.create_tweets_from_twitter(statuses, state: :none, twitter_account: @twitter_account)

    @twitter_account.update_stats!(:home, tweets.map(&:twitter_id).max)
  end

  def load_twitter_account(twitter_account_id)
    @twitter_account = TwitterAccount.find(twitter_account_id)

    @project = @twitter_account.project
    @client = @twitter_account.client
  end

  def mentions_options
    options = { count: 200 }
    options[:since_id] = @twitter_account.max_mentions_tweet_id if @twitter_account.max_mentions_tweet_id.present?
    options
  end

  def home_options
    options = { count: 200 }
    options[:since_id] = @twitter_account.max_home_tweet_id if @twitter_account.max_home_tweet_id.present?
    options
  end

  ##
  # Searches

  def get_search(search_id)
    load_search(search_id)

    response = @client.search(@search.query, search_options)
    tweets = @project.create_tweets_from_twitter(response.statuses, state: :new, twitter_account: @search.twitter_account)

    @search.update_stats!(tweets.map(&:twitter_id).max)
  end

  def load_search(search_id)
    @search = Search.find(search_id)

    @project = @search.project
    @client = @search.twitter_account.client
  end

  def search_options
    options = { count: 100 }
    options[:since_id] = @search.max_tweet_id if @search.max_tweet_id.present?
    options
  end
end
