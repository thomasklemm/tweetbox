# == Schema Information
#
# Table name: twitter_accounts
#
#  auth_scope            :string(255)
#  created_at            :datetime         not null
#  description           :string(255)
#  get_home              :boolean          default(TRUE)
#  get_mentions          :boolean          default(TRUE)
#  id                    :integer          not null, primary key
#  location              :string(255)
#  max_home_tweet_id     :integer
#  max_mentions_tweet_id :integer
#  name                  :string(255)
#  profile_image_url     :string(255)
#  project_id            :integer
#  screen_name           :string(255)
#  token                 :string(255)
#  token_secret          :string(255)
#  twitter_id            :integer
#  uid                   :string(255)
#  updated_at            :datetime         not null
#  url                   :string(255)
#
# Indexes
#
#  index_twitter_accounts_on_project_id          (project_id)
#  index_twitter_accounts_on_project_id_and_uid  (project_id,uid) UNIQUE
#  index_twitter_accounts_on_twitter_id          (twitter_id) UNIQUE
#

Fabricator(:twitter_account) do
  project
  twitter_id        123456789
  uid               "uid_string"
  token             "token_string"
  token_secret      "token_secret_string"
  auth_scope        "read"
end
