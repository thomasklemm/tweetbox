Fabricator(:persisted_signup, from: :signup) do
  name          { sequence(:name)  { |i| "Signal #{i}" } }
  email         { sequence(:email) { |i| "37signals#{i}@example.com" } }
  password      '123123123'
  company_name  '37signals'
end
