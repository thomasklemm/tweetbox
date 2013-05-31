# == Schema Information
#
# Table name: invitations
#
#  account_id :integer          not null
#  code       :text             not null
#  created_at :datetime         not null
#  email      :text             not null
#  expires_at :datetime
#  id         :integer          not null, primary key
#  invitee_id :integer
#  issuer_id  :integer          not null
#  name       :text             not null
#  updated_at :datetime         not null
#  used_at    :datetime
#
# Indexes
#
#  index_invitations_on_account_id  (account_id)
#  index_invitations_on_code        (code) UNIQUE
#

Fabricator(:invitation) do
  email   { sequence(:email) { |i| "invitation#{ i }@example.com" } }
  account
  host    { Fabricate(:user) }
  admin   false
  used    false
  projects { |attrs| [Fabricate(:project, account: attrs[:account]), Fabricate(:project, account: attrs[:account])] }
  project_ids { |attrs| attrs[:projects].map(&:id) }
end
