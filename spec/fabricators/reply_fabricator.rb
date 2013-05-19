# == Schema Information
#
# Table name: replies
#
#  created_at         :datetime         not null
#  id                 :integer          not null, primary key
#  posted_at          :datetime
#  project_id         :integer          not null
#  text               :text             not null
#  tweet_id           :integer          not null
#  twitter_account_id :integer          not null
#  updated_at         :datetime         not null
#  user_id            :integer          not null
#
# Indexes
#
#  index_replies_on_project_id_and_tweet_id  (project_id,tweet_id)
#

Fabricator(:reply) do
  project         nil
  tweet           nil
  twitter_account nil
  text            "MyText"
  posted_at       "2013-05-18 10:03:50"
end
