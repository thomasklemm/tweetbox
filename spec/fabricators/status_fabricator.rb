Fabricator(:status) do
  project
  user
  twitter_account

  full_text 'status full text'
end
