# == Schema Information
#
# Table name: retweets
#
#  created_at         :datetime         not null
#  id                 :integer          not null, primary key
#  posted_at          :datetime
#  project_id         :integer          not null
#  tweet_id           :integer          not null
#  twitter_account_id :integer          not null
#  updated_at         :datetime         not null
#  user_id            :integer          not null
#
# Indexes
#
#  index_retweets_on_project_id  (project_id)
#  index_retweets_on_tweet_id    (tweet_id)
#  index_retweets_on_user_id     (user_id)
#

require 'spec_helper'

describe Retweet do
  pending "add some examples to (or delete) #{__FILE__}"
end
