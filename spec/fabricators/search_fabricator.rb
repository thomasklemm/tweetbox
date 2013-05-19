# == Schema Information
#
# Table name: searches
#
#  active             :boolean          default(TRUE)
#  created_at         :datetime         not null
#  id                 :integer          not null, primary key
#  max_tweet_id       :integer
#  project_id         :integer          not null
#  query              :text             not null
#  twitter_account_id :integer          not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_searches_on_project_id                         (project_id)
#  index_searches_on_project_id_and_twitter_account_id  (project_id,twitter_account_id)
#  index_searches_on_twitter_account_id                 (twitter_account_id)
#

Fabricator(:search) do
  twitter_account
  term            "term"
end
