# SearchWorker
#
# Performs a given Twitter search
#
class SearchWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, backtrace: true

  def perform(search_id, perform_at)
    return if expired?(perform_at)

    search = Search.find(search_id)
    search.fetch_search_results

  # Search could have been removed since scheduling
  rescue ActiveRecord::RecordNotFound
    true
  end

  private

  def expired?(perform_at)
    perform_at < 90.seconds.ago
  end
end
