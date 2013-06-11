class Scheduler
  # Schedule mentions timeline queries for all active accounts
  # to be performed asynchronously
  def self.schedule_mention_timelines
    TwitterAccount.find_each do |twitter_account|
      TwitterWorker.perform_async(:mentions_timeline, twitter_account.id)
    end
  end

  # Schedule user timeline queries for all active accounts
  # to be performed asynchronously
  def self.schedule_user_timelines
    TwitterAccount.find_each do |twitter_account|
      TwitterWorker.perform_async(:user_timeline, twitter_account.id)
    end
  end

  # Schedule searches for specific terms to be performed asynchronously
  def self.schedule_searches
    Search.find_each do |search|
      TwitterWorker.perform_async(:search, search.id)
    end
  end
end
