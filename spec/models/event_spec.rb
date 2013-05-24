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

require 'spec_helper'

describe Event do
  pending "add some examples to (or delete) #{__FILE__}"
end
