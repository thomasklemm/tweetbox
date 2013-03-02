# == Schema Information
#
# Table name: memberships
#
#  account_id :integer
#  admin      :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  updated_at :datetime         not null
#  user_id    :integer
#
# Indexes
#
#  index_memberships_on_user_id_and_account_id  (user_id,account_id) UNIQUE
#

Fabricator(:membership) do
  user
  account
  admin   false
end