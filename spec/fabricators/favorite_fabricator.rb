# == Schema Information
#
# Table name: favorites
#
#  created_at         :datetime         not null
#  id                 :integer          not null, primary key
#  posted_at          :datetime
#  project_id         :integer          not null
#  tweet_id           :integer          not null
#  twitter_account_id :integer
#  undone_at          :datetime
#  updated_at         :datetime         not null
#  user_id            :integer          not null
#
# Indexes
#
#  index_favorites_on_project_id  (project_id)
#  index_favorites_on_tweet_id    (tweet_id)
#  index_favorites_on_user_id     (user_id)
#

Fabricator(:favorite) do
  tweet     nil
  user      nil
  project   nil
  posted_at "2013-05-20 18:59:20"
  undone_at "2013-05-20 18:59:20"
end
