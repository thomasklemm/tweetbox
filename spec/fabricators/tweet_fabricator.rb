Fabricator(:tweet) do
  project
  author
  twitter_id            { sequence(:twitter_id, 1111111111111111111) }
  twitter_account
  text                  "tweet_text"
end
