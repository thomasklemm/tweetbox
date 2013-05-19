# == Schema Information
#
# Table name: events
#
#  created_at   :datetime         not null
#  id           :integer          not null, primary key
#  project_id   :integer          not null
#  target_state :text             not null
#  tweet_id     :integer          not null
#  updated_at   :datetime         not null
#  user_id      :integer          not null
#
# Indexes
#
#  index_events_on_project_id_and_tweet_id  (project_id,tweet_id)
#

class Event < ActiveRecord::Base
  belongs_to :project
  validates :project, presence: true

  belongs_to :tweet, counter_cache: true
  validates :tweet, presence: true

  belongs_to :user
  validates :user, presence: true

  VALID_TARGET_STATES = %w(open closed)
  validates :target_state, presence: true, inclusion: { in: VALID_TARGET_STATES }

  before_validation :assign_project_id_from_tweet

  def project=(ignored)
    raise NotImplementedError, "Use Event#tweet= instead"
  end

  def target_state=(new_target_state)
    super new_target_state.to_s
  end

  private

  def assign_project_id_from_tweet
    self.project_id = tweet.try(:project_id)
  end
end
