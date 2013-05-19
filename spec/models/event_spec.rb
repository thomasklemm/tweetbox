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

require 'spec_helper'

describe Event do
  pending "add some examples to (or delete) #{__FILE__}"
end
