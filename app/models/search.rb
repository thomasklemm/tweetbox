class Search < ActiveRecord::Base
  belongs_to :twitter_account
  belongs_to :project

  validates :twitter_account, :project, :query, presence: true

  before_validation :assign_project_id_from_twitter_account

  def twitter_url
    "https://twitter.com/search/realtime?q=#{ URI::encode(query) }"
  end

  def project=(ignored)
    raise NotImplementedError, "Use Search#twitter_account= instead"
  end

  def update_max_twitter_id(twitter_id)
    update_attributes(max_twitter_id: twitter_id) if twitter_id.to_i > max_twitter_id.to_i
  end

  private

  def assign_project_id_from_twitter_account
    self.project_id = twitter_account.project_id if twitter_account
  end
end
