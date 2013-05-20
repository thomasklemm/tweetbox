# Plans
Plan.create! do |plan|
  plan.name       = 'The awesome trial'
  plan.user_limit = 31
  plan.price      = 0
  plan.trial      = true
end

Plan.create! do |plan|
  plan.name       = 'One man show'
  plan.user_limit = 1
  plan.price      = 0
end

Plan.create! do |plan|
  plan.name       = 'A guy and a gal in a garage'
  plan.user_limit = 2
  plan.price      = 10
end

Plan.create! do |plan|
  plan.name       = 'Three-way mirror'
  plan.user_limit = 3
  plan.price      = 25
end

Plan.create! do |plan|
  plan.name       = 'Four-fingered birds'
  plan.user_limit = 4
  plan.price      = 50
end

Plan.create! do |plan|
  plan.name       = 'Five stars'
  plan.user_limit = 6
  plan.price      = 100
end

Plan.create! do |plan|
  plan.name       = 'Team of ten'
  plan.user_limit = 10
  plan.price      = 250
end

Plan.create! do |plan|
  plan.name       = 'Team of fifteen'
  plan.user_limit = 15
  plan.price      = 500
end

Plan.create! do |plan|
  plan.name       = 'Team of twenty'
  plan.user_limit = 20
  plan.price      = 750
end

Plan.create! do |plan|
  plan.name       = 'Team of twenty-five'
  plan.user_limit = 25
  plan.price      = 1000
end

Plan.create! do |plan|
  plan.name       = 'Stars and stripes forever'
  plan.user_limit = 30
  plan.price      = 1500
end
