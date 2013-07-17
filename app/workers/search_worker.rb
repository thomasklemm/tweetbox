class SearchWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(search_id, perform_at)
    return if expired?(perform_at)

    @search = Search.find(search_id)
    @search.fetch_search_results

  # Search could have been removed since scheduling
  rescue ActiveRecord::RecordNotFound
    false
  end

  private

  def expired?(perform_at)
    perform_at < 90.seconds.ago
  end
end
