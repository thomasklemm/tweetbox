# == Schema Information
#
# Table name: permissions
#
#  created_at    :datetime         not null
#  id            :integer          not null, primary key
#  membership_id :integer          not null
#  project_id    :integer          not null
#  updated_at    :datetime         not null
#  user_id       :integer          not null
#
# Indexes
#
#  index_permissions_on_membership_and_project  (membership_id,project_id) UNIQUE
#  index_permissions_on_user_id_and_project_id  (user_id,project_id)
#

Fabricator(:permission) do
  user
  membership do |attrs|
    account = Fabricate(:account)
    Fabricate(:membership, account: account, user: attrs[:user])
  end

  project { |attrs| Fabricate(:project, account: attrs[:membership].account) }
end
