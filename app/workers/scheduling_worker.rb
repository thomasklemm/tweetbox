# SchedulingWorker
#
# Runs recurringly once a minute and instructs Sidekiq workers
#   to fetch Twitter timelines and searches asynchronously
#
class SchedulingWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { minutely }

  def perform
    perform_timeline_queries_async
    perform_search_queries_async
  end

  private

  def perform_timeline_queries_async
    TwitterAccount.find_each do |twitter_account|
      # Mentions timeline queries once a minute
      MentionsTimelineWorker.perform_async(twitter_account.id, Time.current)

      # User timeline queries once a minute
      UserTimelineWorker.perform_async(twitter_account.id, Time.current)
    end
  end

  def perform_search_queries_async
    Search.find_each do |search|
      # Search queries once a minute
      SearchWorker.perform_async(search.id, Time.current)
    end
  end
end
