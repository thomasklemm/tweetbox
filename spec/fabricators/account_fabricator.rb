# == Schema Information
#
# Table name: accounts
#
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  name       :string(255)
#  updated_at :datetime         not null
#

Fabricator(:account) do
  name { sequence(:name) { |i| "Account #{i}" } }
end
