# == Schema Information
#
# Table name: statuses
#
#  code                  :text             not null
#  created_at            :datetime         not null
#  id                    :integer          not null, primary key
#  in_reply_to_status_id :integer
#  in_reply_to_tweet_id  :integer
#  posted_at             :datetime
#  posted_text           :text
#  project_id            :integer          not null
#  text                  :text             not null
#  twitter_account_id    :integer          not null
#  updated_at            :datetime         not null
#  user_id               :integer          not null
#
# Indexes
#
#  index_statuses_on_code        (code) UNIQUE
#  index_statuses_on_project_id  (project_id)
#

Fabricator(:status) do
  project
  user
  twitter_account
  text              "My status text"
end
