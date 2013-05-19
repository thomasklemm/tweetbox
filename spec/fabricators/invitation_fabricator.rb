# == Schema Information
#
# Table name: invitations
#
#  account_id :integer          not null
#  admin      :boolean          default(FALSE)
#  code       :text             not null
#  created_at :datetime         not null
#  email      :text             not null
#  id         :integer          not null, primary key
#  invitee_id :integer
#  sender_id  :integer          not null
#  updated_at :datetime         not null
#  used       :boolean          default(FALSE)
#
# Indexes
#
#  index_invitations_on_account_id  (account_id)
#  index_invitations_on_code        (code) UNIQUE
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
