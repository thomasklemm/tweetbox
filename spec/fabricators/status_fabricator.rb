Fabricator(:status) do
  project
  user
  twitter_account

  full_text 'status full text'
  posted_text 'status posted text'
end
