# == Schema Information
#
# Table name: accounts
#
#  created_at     :datetime         not null
#  id             :integer          not null, primary key
#  name           :text             not null
#  projects_count :integer
#  updated_at     :datetime         not null
#

require 'spec_helper'

describe Account do
  subject(:account) { Fabricate.build(:account) }
  it { should be_valid }

  it { should have_many(:memberships).dependent(:destroy) }
  it { should have_many(:users).through(:memberships) }
  it { should have_many(:admins).through(:memberships) }
  it { should have_many(:non_admins).through(:memberships) }

  it { should have_many(:projects).dependent(:restrict) }
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

  describe "#make_admin!" do
    pending
  end
end


