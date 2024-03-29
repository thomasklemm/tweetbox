class Search < ActiveRecord::Base
  belongs_to :twitter_account
  belongs_to :project

  delegate :account, to: :project

  validates :twitter_account, :project, :query, presence: true

  before_validation :assign_project_id_from_twitter_account

  def twitter_url
    "https://twitter.com/search/realtime?q=#{ URI::encode(query) }"
  end

  def project=(ignored)
    raise NotImplementedError, "Use Search#twitter_account= instead"
  end

  def state
    self[:state].in?(%w(incoming posted)) ? self[:state] : 'incoming'
  end

  # Fetches the search results from Twitter
  # while only fetching results that we have not already downloaded
  # Returns the persisted tweet records
  def fetch_search_results
    response = twitter_account.client.search(query, search_options)
    statuses = response.statuses
    tweets = TweetMaker.many_from_twitter(statuses, project: project, twitter_account: twitter_account, state: state)
    update_max_twitter_id(tweets.map(&:twitter_id).max)
    tweets
  # If there's an error, just skip execution
  rescue Twitter::Error
    false
  end

  def mixpanel_id
    "search_#{ id }"
  end

  include Rails.application.routes.url_helpers
  def mixpanel_hash
    {
      '$username'          => "Search Query",
      'Query'              => query,
      'Twitter Search URL' => twitter_url,
      'TA Screen Name'     => twitter_account.at_screen_name,
      'TA Name'            => twitter_account.name,
      'TA Twitter URL'     => twitter_account.twitter_url,
      'TA URL'             => dash_twitter_account_url(twitter_account),
      'Project Name'       => project.name,
      'Project URL'        => dash_project_url(project),
      'Account Name'       => account.name,
      'Account URL'        => dash_account_url(account)
    }
  end

  private

  def search_options
    options = { count: 100 } # Max is 100
    # Fetch recent tweets, equivalent to realtime search on Twitter homepage
    options[:result_type] = :recent
    options[:since_id] = max_twitter_id if max_twitter_id.present?
    options
  end

  def assign_project_id_from_twitter_account
    self.project_id = twitter_account.project_id if twitter_account
  end

  def update_max_twitter_id(twitter_id)
    update_attributes(max_twitter_id: twitter_id) if twitter_id.to_i > max_twitter_id.to_i
  end
end
