# == Schema Information
#
# Table name: invitations
#
#  account_id :integer          not null
#  code       :text             not null
#  created_at :datetime         not null
#  email      :text
#  expires_at :datetime
#  id         :integer          not null, primary key
#  invitee_id :integer
#  issuer_id  :integer          not null
#  name       :text
#  updated_at :datetime         not null
#  used_at    :datetime
#
# Indexes
#
#  index_invitations_on_account_id  (account_id)
#  index_invitations_on_code        (code) UNIQUE
#

Fabricator(:invitation) do
  account
  issuer    { Fabricate(:user) }

  name      "Invitee name"
  email     { sequence(:email) { |i| "invitation#{ i }@example.com" } }

  projects { |attrs| [Fabricate(:project, account: attrs[:account]), Fabricate(:project, account: attrs[:account])] }
end
