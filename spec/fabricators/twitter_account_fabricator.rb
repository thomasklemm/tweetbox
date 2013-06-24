# == Schema Information
#
# Table name: twitter_accounts
#
#  access_scope                            :text
#  created_at                              :datetime         not null
#  description                             :text
#  id                                      :integer          not null, primary key
#  location                                :text
#  max_direct_messages_received_twitter_id :integer
#  max_direct_messages_sent_twitter_id     :integer
#  max_mentions_timeline_twitter_id        :integer
#  max_user_timeline_twitter_id            :integer
#  name                                    :text
#  profile_image_url                       :text
#  project_id                              :integer          not null
#  screen_name                             :text
#  token                                   :text             not null
#  token_secret                            :text             not null
#  twitter_id                              :integer          not null
#  uid                                     :text             not null
#  updated_at                              :datetime         not null
#  url                                     :text
#
# Indexes
#
#  index_twitter_accounts_on_project_id                   (project_id)
#  index_twitter_accounts_on_project_id_and_access_scope  (project_id,access_scope)
#  index_twitter_accounts_on_project_id_and_twitter_id    (project_id,twitter_id)
#  index_twitter_accounts_on_twitter_id                   (twitter_id) UNIQUE
#

Fabricator(:twitter_account) do
  project
  twitter_id        { sequence(:twitter_id, 1111111111111111111) }
  uid               "uid_string"
  token             "token_string"
  token_secret      "token_secret_string"
end
