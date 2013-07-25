require 'spec_helper'

describe Account do
  subject(:account) { Fabricate.build(:account) }
  it { should be_valid }

  it { should have_many(:memberships).dependent(:destroy) }
  it { should have_many(:users).through(:memberships) }
  it { should have_many(:admins).through(:memberships) }
  it { should have_many(:non_admins).through(:memberships) }

  it { should have_many(:projects).dependent(:restrict_with_exception) }
  it { should have_many(:invitations).dependent(:destroy) }

  it { should validate_presence_of(:name) }

  describe "with memberships" do
    let(:admins)      { [Fabricate(:user), Fabricate(:user)] }
    let(:non_admins)  { [Fabricate(:user), Fabricate(:user)] }
    let(:non_members) { [Fabricate(:user), Fabricate(:user)] }

    before do
      admins.each do |admin|
        Fabricate(:membership, user: admin, account: account, admin: true)
      end

      non_admins.each do |non_admin|
        Fabricate(:membership, user: non_admin, account: account)
      end
    end

    it "finds admin users" do
      expect(account.admins).to eq(admins)
    end

    it "finds non admin users" do
      expect(account.non_admins).to eq(non_admins)
    end
  end

  describe "#has_member?" do
    it "has a member with a membership" do
      membership = Fabricate(:membership, account: account)
      expect(account).to have_member(membership.user)
    end

    it "doesn't have a member without a membership" do
      membership = Fabricate(:membership, account: account)
      expect(account).not_to have_member(Fabricate(:user))
    end
  end
end

describe Account, 'persisted' do
  subject(:account) { Fabricate(:account) }
  it { should be_valid }

  let!(:user) { Fabricate(:user) }
  let!(:membership) { Fabricate(:membership, account: account, user: user, admin: false) }
  let(:other_user) { Fabricate(:user) }

  let!(:project) { Fabricate(:project, account: account) }

  describe "#grant_admin_membership!(user)" do
    it "ensures that user is member of account" do
      expect{ account.grant_admin_membership!(other_user) }.to raise_error(Pundit::NotAuthorizedError)
    end

    it "sets the admin flag on the account membership" do
      expect(user).to_not be_admin_of(account)
      account.grant_admin_membership!(user)
      expect(user.reload).to be_admin_of(account)
    end

    it "creates permissions for all projects on the account" do
      expect(project).to_not have_member(user)
      account.grant_admin_membership!(user)
      expect(project).to have_member(user)
    end
  end
end
