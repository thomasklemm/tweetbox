Fabricator(:invitation) do
  account
  issuer    { Fabricate(:user) }

  name      "Invitee name"
  email     { sequence(:email) { |i| "invitation#{ i }@example.com" } }

  projects { |attrs| [Fabricate(:project, account: attrs[:account])] }
end
