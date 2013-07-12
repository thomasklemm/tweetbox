# A Scheduler
# Call `Scheduler.perform` every ten minutes
class Scheduler
  def perform
    schedule_timeline_queries
    schedule_search_queries
  end

  private

  def schedule_timeline_queries
    TwitterAccount.find_each do |twitter_account|
      # Perform the first timeline query 20 minutes after the Twitter account
      # has been connected. Before that, schedule queries in an Importer.
      if twitter_account.created_at < 20.minutes.ago
        start_time = twitter_account.created_at + 20.minutes
        end_time = 10.minutes.from_now

        # Don't schedule if start_time is later than end_time
        return if start_time > end_time

        # Query once a minute for the remaining timeframe
        # in the first and second scheduler run after
        # the Twitter account has been connected.
        (start_time.to_i..end_time.to_i).step(60) do |t|
          time = Time.at(t)

          MentionsTimelineWorker.perform_at(time, twitter_account.id)
          UserTimelineWorker.perform_at(time, twitter_account.id)
        end

      # Standard operation
      else
        (0..10).each do |n|
          MentionsTimelineWorker.perform_in(n.minutes, twitter_account.id)
          UserTimelineWorker.perform_in(n.minutes, twitter_account.id)
        end
      end
    end
  end

  def schedule_search_queries
    Search.find_each do |search|
      (0..10).each { |n| SearchWorker.perform_in(n.minutes, search.id) }
    end
  end
end
