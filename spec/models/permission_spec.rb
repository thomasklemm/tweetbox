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

require 'spec_helper'

describe Permission, 'persisted' do
  subject(:permission) { Fabricate(:permission) }
  it { should be_valid }

  it { should belong_to(:project) }
  it { should belong_to(:membership) }
  it { should belong_to(:user) }

  it { should validate_presence_of(:project) }
  it { should validate_presence_of(:membership) }
  it { should validate_presence_of(:user) }
  it { should validate_uniqueness_of(:membership_id).scoped_to(:project_id) }

  it "doesn't allow the same member to be added to a project twice" do
    another_permission = Fabricate.build(:permission, membership: permission.membership, project: permission.project)
    expect(another_permission).not_to be_valid
    expect(another_permission).to have(1).error_on(:membership_id)
  end
end

describe Permission, 'valid account membership' do
  let!(:user) { Fabricate(:user) }
  let!(:account) { Fabricate(:account) }
  let!(:membership) { Fabricate(:membership, account: account, user: user) }
  let!(:project) { Fabricate(:project, account: account) }

  let(:permission_with_membership) { Fabricate.build(:permission, user: nil, membership: membership, project: project)  }
  let(:permission_with_user) { Fabricate.build(:permission, membership: nil, user: user, project: project)  }

  it "sets user from membership" do
    permission_with_membership.valid?
    expect(permission_with_membership.user).to be_present
    expect(permission_with_membership.user).to eq(user)
  end

  it "sets membership from user" do
    permission_with_user.valid?
    expect(permission_with_user.membership).to be_present
    expect(permission_with_user.membership).to eq(membership)
  end
end

