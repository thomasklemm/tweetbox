# == Schema Information
#
# Table name: twitter_accounts
#
#  authorized_for        :text             not null
#  created_at            :datetime         not null
#  description           :text
#  get_home              :boolean          default(TRUE)
#  get_mentions          :boolean          default(TRUE)
#  id                    :integer          not null, primary key
#  location              :text
#  max_home_tweet_id     :integer
#  max_mentions_tweet_id :integer
#  name                  :text
#  profile_image_url     :text
#  project_id            :integer          not null
#  screen_name           :text
#  token                 :text             not null
#  token_secret          :text             not null
#  twitter_id            :integer          not null
#  uid                   :text             not null
#  updated_at            :datetime         not null
#  url                   :text
#
# Indexes
#
#  index_twitter_accounts_on_project_id                 (project_id)
#  index_twitter_accounts_on_project_id_and_twitter_id  (project_id,twitter_id)
#  index_twitter_accounts_on_twitter_id                 (twitter_id) UNIQUE
#

Fabricator(:twitter_account) do
  project
  twitter_id        123456789
  uid               "uid_string"
  token             "token_string"
  token_secret      "token_secret_string"
  auth_scope        "read"
end
