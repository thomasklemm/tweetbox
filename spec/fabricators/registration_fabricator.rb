Fabricator(:registration) do
  first_name    { sequence(:first_name)  { |i| "First #{i}" } }
  last_name     { sequence(:last_name)   { |i| "Last #{i}" } }
  email         { sequence(:email) { |i| "registration_user#{i}@example.com" } }
  password      'password'

  invitation_token { Fabricate(:invitation).token }
end
