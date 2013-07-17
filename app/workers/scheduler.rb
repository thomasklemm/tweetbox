# A Scheduler
# Call `Scheduler.perform` every ten minutes
class Scheduler

  # Schedules all queries for the following ten minutes
  # Call every ten minutes
  def self.perform
    schedule_timeline_queries
    schedule_search_queries
  end

  # Schedules timeline queries for the initial twenty minutes
  # after creation of a given Twitter account
  def self.schedule_initial_timeline_queries(twitter_account)
    schedule_initial_mentions_timeline_queries(twitter_account)
    schedule_initial_user_timeline_queries(twitter_account)
  end

  private

  def self.schedule_timeline_queries
    TwitterAccount.find_each do |twitter_account|
      # Perform the first timeline query 20 minutes after the Twitter account
      # has been connected. Before that, schedule queries in an Importer.
      if twitter_account.created_at > 20.minutes.ago
        start_time = twitter_account.created_at + 20.minutes
        end_time = 10.minutes.from_now

        # Don't schedule if start_time is later than end_time
        return if start_time > end_time

        # Query once a minute for the remaining timeframe
        # in the first and second scheduler run after
        # the Twitter account has been connected.

        # Mentions timeline
        (start_time.to_i..end_time.to_i).step(60) do |t|
          perform_at = Time.at(t)
          MentionsTimelineWorker.perform_at(perform_at, twitter_account.id, perform_at)
        end

        # User timeline
        (start_time.to_i..end_time.to_i).step(30) do |t|
          perform_at = Time.at(t)
          UserTimelineWorker.perform_at(perform_at, twitter_account.id, perform_at)
        end

      # Standard operation
      else
        # Mentions timeline
        # every 60 seconds
        (0..9).each do |n|
          perform_at = n.minutes.from_now
          MentionsTimelineWorker.perform_at(perform_at, twitter_account.id, perform_at)
        end

        # User timeline
        # every 30 seconds
        (0..570).step(30) do |n|
          perform_at = n.seconds.from_now
          UserTimelineWorker.perform_at(perform_at, twitter_account.id, perform_at)
        end
      end
    end
  end

  def self.schedule_search_queries
    Search.find_each do |search|
      (0..9).each do |n|
        perform_at = n.minutes.from_now
        SearchWorker.perform_at(perform_at, search.id, perform_at)
      end
    end
  end

  ##
  # First few timeslots

  # Schedule mentions timeline queries for the first twenty minutes
  # after a Twitter account is created from Omniauth
  def self.schedule_initial_mentions_timeline_queries(twitter_account)
    [2, 4, 6, 8, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20].each do |n|
      perform_at = twitter_account.created_at + n.minutes
      MentionsTimelineWorker.perform_at(perform_at, twitter_account.id, perform_at)
    end
  end

  # Schedule user timeline queries for the first twenty minutes
  # after a Twitter account is created from Omniauth
  def self.schedule_initial_user_timeline_queries(twitter_account)
    (30..1200).step(30) do |n|
      perform_at = twitter_account.created_at + n.seconds
      UserTimelineWorker.perform_at(perform_at, twitter_account.id, perform_at)
    end
  end

end
