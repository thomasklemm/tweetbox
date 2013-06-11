class TwitterWorker
  include Sidekiq::Worker

  TYPES = %w(mentions_timeline user_timeline search)

  # Options / arguments:
  #   - type: Required type of the query to be performed, should be in [:mentions, :home, :search]
  #   - twitter_account_id: Required for mentions and home timeline queries
  #   - search_id: Required for search queries
  def perform(type, twitter_account_or_search_id)
    type &&= type.to_s

    # Raise unless type is whitelisted
    valid_type?(type) or raise_unknown_type(type)

    # Delegate to the matching type action
    case type
    when 'mentions_timeline' then get_mentions_timeline_(twitter_account_or_search_id)
    when 'user_timeline'     then get_user_timeline(twitter_account_or_search_id)
    when 'search'            then get_search(twitter_account_or_search_id)
    end

  rescue Twitter::Error::TooManyRequests
    puts "TwitterWorker: Caught Twitter::Error::TooManyRequests error for #{ type }, #{ twitter_account_or_search_id }"
    false
  end

  private

  def valid_type?(type)
    TYPES.include?(type)
  end

  def raise_invalid_type
    raise StandardError, "TwitterWorker: #{ type } is not recognized as a valid type. Must be in #{ TYPES.join(', ') }."
  end

  ##
  # Mentions and home

  def get_mentions_timeline(twitter_account_id)
    load_twitter_account(twitter_account_id)
    load_project

    statuses = @twitter_account.client.mentions_timeline(mentions_timeline_options)
    tweets = @project.create_tweets_from_twitter(statuses, state: :new, twitter_account: @twitter_account)

    update_twitter_account_stats(:mentions_timeline, tweets)
  end

  def get_user_timeline(twitter_account_id)
    load_twitter_account(twitter_account_id)
    load_project

    statuses = @twitter_account.client.user_timeline(user_timeline_options)
    tweets = @project.create_tweets_from_twitter(statuses, state: :none, twitter_account: @twitter_account)

    update_twitter_account_stats(:user_timeline, tweets)
  end

  def load_twitter_account(twitter_account_id)
    @twitter_account = TwitterAccount.find(twitter_account_id)
  end

  def load_project
    @project = @twitter_account.project
  end

  def mentions_timeline_options
    since_id = @twitter_account.max_mentions_timeline_twitter_id

    options = { count: 200 }
    options[:since_id] = since_id if since_id.present?
    options
  end

  def user_timeline_options
    since_id = @twitter_account.max_user_timeline_twitter_id

    options = { count: 200 }
    options[:since_id] = since_id if since_id.present?
    options
  end

  def update_twitter_account_statistics(type)
    valid_type?(type) or raise_unknown_type(type)
    @twitter_account.update_statistics(type, tweets.map(&:twitter_id).max)
  end

  ##
  # Searches

  def get_search(search_id)
    load_search(search_id)

    response = @twitter_account.client.search(@search.query, search_options)
    tweets = @project.create_tweets_from_twitter(response.statuses, state: :new, twitter_account: @twitter_account)

    @search.update_stats(tweets.map(&:twitter_id).max)
  end

  def load_search(search_id)
    @search = Search.find(search_id)
    @project = @search.project
  end

  def search_options
    since_id = @search.max_twitter_id

    options = { count: 100 }
    options[:since_id] = since_id if since_id.present?
    options
  end
end
