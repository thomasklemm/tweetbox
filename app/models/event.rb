# == Schema Information
#
# Table name: events
#
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  kind       :text             not null
#  project_id :integer          not null
#  text       :text
#  tweet_id   :integer          not null
#  updated_at :datetime         not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_events_on_project_id  (project_id)
#  index_events_on_tweet_id    (tweet_id)
#  index_events_on_user_id     (user_id)
#

class Event < ActiveRecord::Base
  belongs_to :tweet
  belongs_to :user
  belongs_to :project
  validates :tweet, :user, :project, presence: true

  VALID_KINDS_OF_EVENTS = %w(opened closed posted replied retweeted favorited unfavorited)
  validates :kind, presence: true, inclusion: { in: VALID_KINDS_OF_EVENTS }

  def kind=(new_kind)
    super(new_kind.to_s)
  end

  before_validation :assign_project_id_from_tweet

  def project=(ignored)
    raise NotImplementedError, "Use Event#tweet= instead"
  end

  private

  def assign_project_id_from_tweet
    self.project_id = tweet.try(:project_id)
  end
end
