Fabricator(:invitation_signup) do
  invitation { Fabricate(:invitation) }
  user       { Fabricate(:user) }
end
