Fabricator(:signup) do
  first_name    { sequence(:first_name)  { |i| "First #{i}" } }
  last_name     { sequence(:last_name)   { |i| "Last #{i}" } }
  email         { sequence(:email) { |i| "signup_user_#{i}@example.com" } }
  password      'password'
  company_name  'Company name'
end
