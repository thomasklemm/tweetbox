# == Schema Information
#
# Table name: tweets
#
#  author_id             :integer
#  created_at            :datetime         not null
#  id                    :integer          not null, primary key
#  in_reply_to_status_id :integer
#  in_reply_to_user_id   :integer
#  previous_tweet_ids    :integer
#  project_id            :integer
#  text                  :text
#  twitter_account_id    :integer
#  twitter_id            :integer          not null
#  updated_at            :datetime         not null
#  workflow_state        :text
#
# Indexes
#
#  index_tweets_on_author_id                  (author_id)
#  index_tweets_on_previous_tweet_ids         (previous_tweet_ids)
#  index_tweets_on_project_id                 (project_id)
#  index_tweets_on_project_id_and_author_id   (project_id,author_id)
#  index_tweets_on_project_id_and_twitter_id  (project_id,twitter_id) UNIQUE
#  index_tweets_on_twitter_id                 (twitter_id)
#  index_tweets_on_workflow_state             (workflow_state)
#

Fabricator(:tweet) do
  project
  author
  twitter_id            { sequence(:twitter_id, 111111111111111111) }
  text                  "tweet_text"
end
