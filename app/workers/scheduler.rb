# A simple Scheduler,
# called every 10 minutes by the Heroku scheduling addon
class Scheduler
  def self.schedule_queries_for_ten_minutes
    TwitterAccount.find_each do |twitter_account|
      (1..10).each do |i|
        TwitterWorker.perform_in(i.minutes, :mentions_timeline, twitter_account.id)
        TwitterWorker.perform_in(i.minutes, :user_timeline, twitter_account.id)
      end
    end

    Search.find_each do |search|
      [1 3 5 7 9].each { |i| TwitterWorker.perform_in(i.minutes, :search, search.id) }
    end
  end
end

# # Schedule mentions timeline queries for all twitter accounts to be performed asynchronously
# def self.schedule_mention_timelines
#   TwitterAccount.find_each do |twitter_account|
#     TwitterWorker.perform_async(:mentions_timeline, twitter_account.id)
#   end
# end

# # Schedule user timeline queries for all twitter accounts to be performed asynchronously
# def self.schedule_user_timelines
#   TwitterAccount.find_each do |twitter_account|
#     TwitterWorker.perform_async(:user_timeline, twitter_account.id)
#   end
# end

# # Schedule searches for specific terms to be performed asynchronously
# def self.schedule_searches
#   Search.find_each do |search|
#     TwitterWorker.perform_async(:search, search.id)
#   end
# end
