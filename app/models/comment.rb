# == Schema Information
#
# Table name: comments
#
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  project_id :integer          not null
#  text       :text             not null
#  tweet_id   :integer          not null
#  updated_at :datetime         not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_comments_on_project_id_and_tweet_id  (project_id,tweet_id)
#

class Comment < ActiveRecord::Base
  belongs_to :project
  validates :project, presence: true

  belongs_to :tweet
  validates :tweet, presence: true

  belongs_to :user
  validates :user, presence: true

  # Comment text
  validates :text, presence: true

  before_validation :assign_project_id_from_tweet

  def project=(ignored)
    raise NotImplementedError, "Use Comment#tweet= instead"
  end

  private

  def assign_project_id_from_tweet
    self.project_id = tweet.try(:project_id)
  end
end
