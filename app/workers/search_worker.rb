class SearchWorker
  include Sidekiq::Worker

  def perform(search_id)
    @search = Search.find(search_id)
    @search.fetch_search_results

  # Search could have been removed since scheduling
  rescue ActiveRecord::RecordNotFound
    false
  end
end
