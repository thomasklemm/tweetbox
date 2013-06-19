Fabricator(:registration) do
  name          { sequence(:name)  { |i| "User #{i}" } }
  email         { sequence(:email) { |i| "registration_user#{i}@example.com" } }
  password      'password'

  invitation_code { Fabricate(:invitation).code }
end
