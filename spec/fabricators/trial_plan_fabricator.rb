Fabricator(:trial_plan, class_name: :plan) do
  name       "Trial plan"
  price      0
  user_limit 30
  trial      true
end
