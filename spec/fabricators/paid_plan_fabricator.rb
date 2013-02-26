# == Schema Information
#
# Table name: plans
#
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  name       :string(255)
#  price      :integer          default(0), not null
#  trial      :boolean          default(FALSE), not null
#  updated_at :datetime         not null
#  user_limit :integer          not null
#

Fabricator(:paid_plan, from: :plan) do
  name       "Paid plan"
  price      1
  user_limit 1
  trial      false
end
