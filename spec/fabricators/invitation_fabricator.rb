Fabricator(:invitation) do
  account
  issuer    { Fabricate(:user) }

  name      "Invitee name"
  email     { sequence(:email) { |i| "invitation#{ i }@example.com" } }

  # TODO: Setting a project causes failing specs with error message
  # 'InvitationProject "requires an invitation"'.
  # Worked fine in Rails 3.2.
  # projects { |attrs| [Fabricate(:project, account: attrs[:account])] }
end
