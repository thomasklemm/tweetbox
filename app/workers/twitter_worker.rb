class TwitterWorker
  include Sidekiq::Worker

  # Valid, whitelisted work types
  TYPES = %w(mentions_timeline user_timeline search)

  def perform(type, twitter_account_or_search_id)
    type &&= type.to_s

    # Raise unless type is whitelisted
    valid_type?(type) or raise_invalid_type(type)

    # Delegate to the matching type action
    case type
    when 'mentions_timeline' then get_mentions_timeline(twitter_account_or_search_id)
    when 'user_timeline'     then get_user_timeline(twitter_account_or_search_id)
    when 'search'            then get_search(twitter_account_or_search_id)
    end

  # In case that too many requests are being sent for a twitter account's timeline
  rescue Twitter::Error::TooManyRequests
    Rails.logger.info "TwitterWorker raised Twitter::Error::TooManyRequests for '#{ type }, #{ twitter_account_or_search_id }'."
    false
  end

  private

  ##
  # Mentions and user timelines

  def get_mentions_timeline(twitter_account_id)
    load_twitter_account_and_project(twitter_account_id)

    statuses = @twitter_account.client.mentions_timeline(mentions_timeline_options)
    tweets = @project.create_tweets_from_twitter(statuses, state: :new, twitter_account: @twitter_account)

    @twitter_account.update_max_mentions_timeline_twitter_id(max_twitter_id(tweets))
  end

  def get_user_timeline(twitter_account_id)
    load_twitter_account_and_project(twitter_account_id)

    statuses = @twitter_account.client.user_timeline(user_timeline_options)
    tweets = @project.create_tweets_from_twitter(statuses, state: :none, twitter_account: @twitter_account)

    @twitter_account.update_max_user_timeline_twitter_id(max_twitter_id(tweets))
  end

  def load_twitter_account_and_project(twitter_account_id)
    @twitter_account = TwitterAccount.find(twitter_account_id)
    @project = @twitter_account.project
  end

  ##
  # Searches

  def get_search(search_id)
    load_search_and_project(search_id)

    response = @twitter_account.client.search(@search.query, search_options)
    tweets = @project.create_tweets_from_twitter(response.statuses, state: :new, twitter_account: @twitter_account)

    @search.update_max_twitter_id(max_twitter_id(tweets))
  end

  def load_search_and_project(search_id)
    @search = Search.find(search_id)
    @project = @search.project
    @twitter_account = @search.twitter_account
  end

  ##
  # Options

  def mentions_timeline_options
    since_id = @twitter_account.max_mentions_timeline_twitter_id

    options = { count: 200 } # Max is 200
    options[:since_id] = since_id if since_id.present?
    options
  end

  def user_timeline_options
    since_id = @twitter_account.max_user_timeline_twitter_id

    options = { count: 200 } # Max is 200
    options[:since_id] = since_id if since_id.present?
    options
  end

  def search_options
    since_id = @search.max_twitter_id

    options = { count: 100 } # Max is 100
    options[:since_id] = since_id if since_id.present?
    options
  end

  ##
  # Shared

  def valid_type?(type)
    TYPES.include?(type)
  end

  def raise_invalid_type(type)
    raise StandardError, "TwitterWorker: #{ type } isn't a valid type."
  end

  def max_twitter_id(tweets)
    tweets.map(&:twitter_id).max
  end
end
