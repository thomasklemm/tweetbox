# == Schema Information
#
# Table name: accounts
#
#  created_at     :datetime         not null
#  id             :integer          not null, primary key
#  name           :text             not null
#  projects_count :integer
#  updated_at     :datetime         not null
#

Fabricator(:account) do
  name "Account name"
end
