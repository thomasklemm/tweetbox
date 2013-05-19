# == Schema Information
#
# Table name: accounts
#
#  created_at       :datetime         not null
#  id               :integer          not null, primary key
#  name             :text             not null
#  plan_id          :integer
#  trial_expires_at :datetime
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_accounts_on_plan_id           (plan_id)
#  index_accounts_on_trial_expires_at  (trial_expires_at)
#

require 'spec_helper'

describe Account do
  subject { Fabricate(:account) }
  it { should be_valid }

  it { should have_many(:memberships).dependent(:destroy) }
  it { should have_many(:users).through(:memberships) }
  it { should have_many(:admins).through(:memberships) }
  it { should have_many(:non_admins).through(:memberships) }

  it { should have_many(:projects).dependent(:restrict) }
  it { should have_many(:invitations).dependent(:destroy) }

  it { should belong_to(:plan) }
  it { should validate_presence_of(:plan) }
  describe "delegates to plan" do
    it { should respond_to(:free?) }
    it { should respond_to(:billed?) }
    it { should respond_to(:trial?) }
  end

  it { should validate_presence_of(:name) }

  describe "with memberships" do
    let!(:account)     { Fabricate(:account) }
    let!(:admins)      { [Fabricate(:user), Fabricate(:user)] }
    let!(:non_admins)  { [Fabricate(:user), Fabricate(:user)] }
    let!(:non_members) { [Fabricate(:user), Fabricate(:user)] }

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

    it "finds emails for admin users" do
      expect(account.admin_emails).to eq(admins.map(&:email))
    end
  end

  let(:account) { Fabricate(:account) }

  it "has a member with a membership" do
    membership = Fabricate(:membership, account: account)
    expect(account).to have_member(membership.user)
  end

  it "doesn't have a member without a membership" do
    membership = Fabricate(:membership, account: account)
    expect(account).not_to have_member(Fabricate(:user))
  end

  it "has a count of users" do
    Fabricate(:membership, account: account)
    expect(account.users_count).to eq(1)

    Fabricate(:membership, account: account)
    expect(account.users_count).to eq(2)
  end

  it "has a count of projects" do
    Fabricate(:project, account: account)
    expect(account.projects_count).to eq(1)

    Fabricate(:project, account: account)
    expect(account.projects_count).to eq(2)
  end

  it "finds memberships by name" do
    memberships = [Fabricate(:membership, account: account), Fabricate(:membership, account: account)]
    expect(account.memberships_by_name).to eq(memberships)
  end

  let(:trial_plan) { Fabricate(:trial_plan) }
  let(:paid_plan)  { Fabricate(:paid_plan) }

  it "is expired with a trial plan after 31 days" do
    account = Fabricate(:account, created_at: 31.days.ago, plan: trial_plan)
    expect(account).to be_expired
  end

  it "isn't expired with a trial plan before 31 days" do
    account = Fabricate(:account, created_at: (31.days.ago + 1.second), plan: trial_plan)
    expect(account).not_to be_expired
  end

  it "isn't expired with paid plan after 31 days" do
    account = Fabricate(:account, created_at: (60.days.ago), plan: paid_plan)
    expect(account).not_to be_expired
  end

  it "isn't expired without an expiration date after 31 days" do
    account = Fabricate(:account, created_at: 60.days.ago, plan: trial_plan)
    account.trial_expires_at = nil
    account.save!

    expect(account).not_to be_expired
  end
end


