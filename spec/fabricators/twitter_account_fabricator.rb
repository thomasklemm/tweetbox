Fabricator(:twitter_account) do
  project
  twitter_id        { sequence(:twitter_id, 1111111111111111111) }
  uid               "uid_string"
  token             "token_string"
  token_secret      "token_secret_string"
end
