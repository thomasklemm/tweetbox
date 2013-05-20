# == Schema Information
#
# Table name: transitions
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
#  index_transitions_on_project_id  (project_id)
#  index_transitions_on_tweet_id    (tweet_id)
#  index_transitions_on_user_id     (user_id)
#

class Transition < Action
  VALID_TARGET_STATES = %w(open closed)
  validates :target_state, inclusion: { in: VALID_TARGET_STATES }

  # Both strings and symbols are now recognized for the target_state
  def target_state=(new_state)
    super new_state.to_s
  end
end
