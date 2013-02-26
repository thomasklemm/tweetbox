# == Schema Information
#
# Table name: permissions
#
#  created_at    :datetime         not null
#  id            :integer          not null, primary key
#  membership_id :integer
#  project_id    :integer
#  updated_at    :datetime         not null
#  user_id       :integer
#
# Indexes
#
#  index_permissions_on_membership_and_project  (membership_id,project_id) UNIQUE
#  index_permissions_on_user_id_and_project_id  (user_id,project_id)
#

require 'spec_helper'

describe Permission do
  let!(:membership) { Fabricate(:membership) }
  let!(:project) { Fabricate(:project) }
  subject { Fabricate(:permission, membership: membership, project: project) }
  it { should be_valid }

  it { should belong_to(:membership) }
  it { should belong_to(:project) }
  it { should belong_to(:user) }

  it { should validate_presence_of(:project_id) }
  it { should validate_presence_of(:membership_id) }
  it { should validate_uniqueness_of(:membership_id).scoped_to(:project_id) }

  describe '#user_id' do
    it 'is required' do
      permission = Fabricate.build(:permission, membership: nil)
      expect(permission).not_to be_valid
      expect(permission).to have(1).error_on(:user_id)
    end
  end

  let(:permission) { Fabricate(:permission) }

  it "doesn't allow the same member to be added to a project twice" do
    another_permission = Fabricate.build(:permission, membership: permission.membership, project: permission.project)
    expect(another_permission).not_to be_valid
    expect(another_permission).to have(1).error_on(:membership_id)
  end

  it "allows different members to be added to a project" do
    another_permission = Fabricate(:permission, project: permission.project)
    expect(another_permission).to be_valid
  end

  it "caches the user from the account membership" do
    membership = Fabricate(:membership)
    permission = Fabricate(:permission, membership: membership)
    expect(permission.user_id).to eq(membership.user_id)
  end

  it "doesn't allow the user to be assigned" do
    expect { subject.user = Fabricate(:user) }.to raise_error(NotImplementedError)
  end
end
