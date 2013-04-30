# == Schema Information
#
# Table name: invitations
#
#  account_id :integer
#  admin      :boolean          default(FALSE), not null
#  code       :string(255)
#  created_at :datetime         not null
#  email      :string(255)
#  id         :integer          not null, primary key
#  invitee_id :integer
#  sender_id  :integer
#  updated_at :datetime         not null
#  used       :boolean          default(FALSE), not null
#
# Indexes
#
#  index_invitations_on_account_id  (account_id)
#

Fabricator(:invitation) do
  email   { sequence(:email) { |i| "invitation#{ i }@example.com" } }
  account
  sender  { Fabricate(:user) }
  admin   false
  used    false
  projects { |attrs| [Fabricate(:project, account: attrs[:account]), Fabricate(:project, account: attrs[:account])] }
  project_ids { |attrs| attrs[:projects].map(&:id) }
end
