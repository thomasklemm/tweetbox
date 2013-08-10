Fabricator(:status) do
  project
  user
  twitter_account
  text Tokenizer.random_token(160)
end
