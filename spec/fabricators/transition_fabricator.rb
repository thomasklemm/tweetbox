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

Fabricator(:transition) do
  tweet        nil
  user         nil
  project      nil
  target_state "MyText"
end
