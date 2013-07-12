Fabricator(:user) do
  name  { sequence(:name)  { |i| "User #{i}" } }
  email { sequence(:email) { |i| "user#{i}@example.com" } }
  password              'password'
  password_confirmation { |attrs| attrs[:password]  }
  confirmed_at           Time.current
end
