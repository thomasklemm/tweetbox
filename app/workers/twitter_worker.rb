class TwitterWorker
  include Sidekiq::Worker

  def perform(type, twitter_account_id, term=nil)
    @twitter_account = TwitterAccount.find(twitter_account_id)
    @client = @twitter_account.client

    case type.to_sym
    when :mentions then get_mentions
    when :home then get_home
    when :search then get_search(term)
    else raise "TwitterWorker: Please pass a valid type"
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
    tweets = @client.x
    # use max_mentions_tweet_id
  end

  def get_home
    tweets = @client.x
    # use max_home_tweet_id
  end

  def get_search(term)
    tweets = @client.x
    # how should we cache the current max tweet id?
  end
end
