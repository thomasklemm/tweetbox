Fabricator(:user) do
  first_name    { sequence(:first_name)  { |i| "First #{i}" } }
  last_name     { sequence(:last_name)   { |i| "Last #{i}" } }
  email { sequence(:email) { |i| "user#{i}@example.com" } }
  password              'password'
  password_confirmation { |attrs| attrs[:password]  }
  confirmed_at           Time.current
end
