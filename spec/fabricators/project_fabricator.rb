# == Schema Information
#
# Table name: projects
#
#  account_id :integer
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  name       :string(255)
#  updated_at :datetime         not null
#
# Indexes
#
#  index_projects_on_account_id  (account_id)
#

Fabricator(:project) do
  name    { sequence(:name) { |i| "Project #{i}" } }
  account
end
