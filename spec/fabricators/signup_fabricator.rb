Fabricator(:signup) do
  name          { sequence(:name)  { |i| "User #{i}" } }
  email         { sequence(:email) { |i| "user#{i}@example.com" } }
  password      'password'
  company_name  'Account'
end
