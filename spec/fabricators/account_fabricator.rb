# == Schema Information
#
# Table name: accounts
#
#  created_at       :datetime         not null
#  id               :integer          not null, primary key
#  name             :text
#  plan_id          :integer
#  trial_expires_at :datetime
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_accounts_on_plan_id           (plan_id)
#  index_accounts_on_trial_expires_at  (trial_expires_at)
#

Fabricator(:account) do
  name { sequence(:name) { |i| "Account #{i}" } }
  plan { Fabricate(:trial_plan) }
end
