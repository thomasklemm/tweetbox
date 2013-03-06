Fabricator(:invitation_signup_with_existing_user, from: :invitation_signup) do
  invitation { Fabricate(:invitation) }
  code       { |attrs| attrs[:invitation].code }
  user       { Fabricate(:user) }
end

Fabricator(:invitation_signup_with_new_user, from: :invitation_signup) do
  invitation { Fabricate(:invitation) }
  code       { |attrs| attrs[:invitation].code }
  name       { sequence(:name)  { |i| "User #{i}" } }
  email      { sequence(:email) { |i| "invitation_signup_user#{i}@example.com" } }
  password   'password'
end
