class FakeTweetMaker
  attr_reader :project, :query, :count, :state

  def initialize(project, query, count=1, state=:incoming)
    @project = project
    @query = query
    @count = count
    @state = state
  end

  def make
    response = twitter_client.search(query, search_options)
    statuses = response.statuses
    tweets = TweetMaker.many_from_twitter(statuses, project: project, state: state)
  end

  private

  def twitter_client
    RandomTwitterClient.new
  end

  def search_options
    options = { count: count } # Max is 100
    # Fetch recent tweets, equivalent to realtime search on Twitter homepage
    options[:result_type] = :recent
    # options[:since_id] = nil
    options
  end
end
