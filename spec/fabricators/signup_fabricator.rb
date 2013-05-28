Fabricator(:signup) do
  name          { sequence(:name)  { |i| "User #{i}" } }
  email         { sequence(:email) { |i| "signup_user#{i}@example.com" } }
  password      'password'
  company_name  'Company name'
end
