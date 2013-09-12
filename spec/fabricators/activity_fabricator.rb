Fabricator(:activity) do
  tweet
  user
  kind    Activity::VALID_KINDS.sample
end
