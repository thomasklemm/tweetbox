# == Schema Information
#
# Table name: projects
#
#  account_id                 :integer          not null
#  created_at                 :datetime         not null
#  default_twitter_account_id :integer
#  id                         :integer          not null, primary key
#  name                       :text             not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_projects_on_account_id  (account_id)
#

Fabricator(:project) do
  account
  name    "Project name"
end
