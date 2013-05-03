# == Schema Information
#
# Table name: searches
#
#  created_at         :datetime         not null
#  id                 :integer          not null, primary key
#  project_id         :integer
#  term               :text
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

  validates :twitter_account, :project, :term, presence: true

  before_validation :assign_project_id_from_twitter_account

  def project=(ignored)
    raise NotImplementedError, "Use Search#twitter_account= instead"
  end

  private

  def assign_project_id_from_twitter_account
    self.project_id = twitter_account.project_id if twitter_account
  end
end
