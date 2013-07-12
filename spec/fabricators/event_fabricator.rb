Fabricator(:event) do
  tweet
  user
  kind    Event::VALID_KINDS.sample
end
