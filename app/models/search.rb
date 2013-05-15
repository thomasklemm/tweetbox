# == Schema Information
#
# Table name: searches
#
#  active             :boolean          default(TRUE)
#  created_at         :datetime         not null
#  id                 :integer          not null, primary key
#  max_tweet_id       :integer
#  project_id         :integer
#  query              :text             not null
#  twitter_account_id :integer
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_searches_on_project_id          (project_id)
#  index_searches_on_twitter_account_id  (twitter_account_id)
#

class Search < ActiveRecord::Base
  belongs_to :twitter_account
  belongs_to :project

  validates :twitter_account, :project, :query, presence: true

  before_validation :assign_project_id_from_twitter_account

  def project=(ignored)
    raise NotImplementedError, "Use Search#twitter_account= instead"
  end

  def update_stats!(new_max_tweet_id)
    self.max_tweet_id = new_max_tweet_id if new_max_tweet_id.to_i > max_tweet_id.to_i
    self.save!
  end

  private

  def assign_project_id_from_twitter_account
    self.project_id = twitter_account.project_id if twitter_account
  end
end
