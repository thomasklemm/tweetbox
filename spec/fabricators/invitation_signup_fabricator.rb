Fabricator(:invitation_signup, from: :'invitation/signup') do
  invitation

  name       { sequence(:name)  { |i| "User #{i}" } }
  email      { sequence(:email) { |i| "invitation_signup_user#{i}@example.com" } }
  password   'password'
end