class Scheduler
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
end
