# == Schema Information
#
# Table name: searches
#
#  active             :boolean          default(TRUE)
#  created_at         :datetime         not null
#  id                 :integer          not null, primary key
#  max_twitter_id     :integer
#  project_id         :integer          not null
#  query              :text             not null
#  twitter_account_id :integer          not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_searches_on_project_id                         (project_id)
#  index_searches_on_project_id_and_twitter_account_id  (project_id,twitter_account_id)
#  index_searches_on_twitter_account_id                 (twitter_account_id)
#

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
