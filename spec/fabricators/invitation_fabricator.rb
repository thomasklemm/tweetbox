Fabricator(:invitation) do
  account
  issuer    { Fabricate(:user) }

  first_name "First"
  last_name  "Last"
  email     { sequence(:email) { |i| "invitation#{ i }@example.com" } }

  projects { |attrs| [Fabricate(:project, account: attrs[:account])] }
end
