Fabricator(:author) do
  project
  twitter_id        { sequence(:twitter_id, 111111111111111111) }
  screen_name       "author_screen_name"
end
