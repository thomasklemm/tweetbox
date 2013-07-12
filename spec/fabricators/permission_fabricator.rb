Fabricator(:permission) do
  user
  membership { |attrs| Fabricate(:membership, account: Fabricate(:account), user: attrs[:user]) }
  project { |attrs| Fabricate(:project, account: attrs[:membership].account) }
end
