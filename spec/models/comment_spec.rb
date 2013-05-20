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
#  index_comments_on_project_id  (project_id)
#  index_comments_on_tweet_id    (tweet_id)
#  index_comments_on_user_id     (user_id)
#

require 'spec_helper'

describe Comment do
  pending "add some examples to (or delete) #{__FILE__}"
end
