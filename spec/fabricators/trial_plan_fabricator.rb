Fabricator(:trial_plan, from: :plan) do
  name       "Trial plan"
  price      0
  user_limit 30
  trial      true
end
