# == Schema Information
#
# Table name: projects
#
#  account_id :integer          not null
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  name       :text             not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_projects_on_account_id  (account_id)
#

require 'spec_helper'

describe Project do
  subject { Fabricate(:project) }
  it { should be_valid }

  it { should belong_to(:account) }
  it { should have_many(:permissions) }
  it { should have_many(:users).through(:permissions) }

  it { should validate_presence_of(:account) }
  it { should validate_presence_of(:name) }

  it { should have_many(:twitter_accounts).dependent(:destroy) }
  it { should have_many(:tweets).dependent(:destroy) }
  it { should have_many(:authors).dependent(:destroy) }

  it "finds projects visible to a user" do
    account = Fabricate(:account)
    user = Fabricate(:user)
    membership = Fabricate(:membership, user: user, account: account)
    visible_projects = [Fabricate(:project, account: account),
                        Fabricate(:project, account: account)]
    invisible_projects = Fabricate(:project, account: account)
    visible_projects.each do |visible_project|
      Fabricate(:permission, project: visible_project, membership: membership)
    end

    expect(Project.visible_to(user).to_a).to eq(visible_projects)
  end

  it "returns projects by name" do
    Fabricate(:project, name: 'def')
    Fabricate(:project, name: 'abc')
    Fabricate(:project, name: 'ghi')

    expect(Project.by_name.map(&:name)).to eq(%w(abc def ghi))
  end
end

shared_examples_for "default project permissions" do
  it "is viewable by admins by default" do
    admins.each do |admin|
      expect(subject.users).to include(admin)
    end
  end

  it "isn't viewable by non-members" do
    expect(subject.users).not_to include(non_admin)
    expect(subject.users).not_to include(non_member)
  end
end

describe Project, "for an account with admin and non-admin users" do
  let!(:account)       { Fabricate(:account, name: 'Account') }
  let!(:other_account) { Fabricate(:account, name: 'Other') }
  let!(:non_admin)     { Fabricate(:user) }
  let!(:admins)        { [Fabricate(:user), Fabricate(:user)] }
  let!(:non_member)    { Fabricate(:user) }
  subject              { Fabricate(:project, account: account) }

  before do
    Fabricate(:membership, account: account, user: non_admin, admin: false)
    Fabricate(:membership, account: other_account, user: non_member, admin: true)

    admins.each do |admin|
      Fabricate(:membership, account: account, user: admin, admin: true)
    end
  end

  context "before saving" do
    it_should_behave_like "default project permissions"
  end

  context "after saving" do
    before do
      subject.save!
      subject.reload
    end
    it_should_behave_like "default project permissions"
  end
end

describe Project, "saved" do
  let!(:project) { Fabricate(:project) }

  it "has a member with a membership" do
    user = Fabricate(:user)
    membership = Fabricate(:membership, account: project.account, user: user)
    permission = Fabricate(:permission, project: project, membership: membership)
    expect(project).to have_member(user)
  end

  it "doesn't have a member without a membership" do
    user = Fabricate(:user)
    expect(project).not_to have_member(user)
  end
end

describe Project, "assigning users on update" do
  let!(:project)        { Fabricate(:project) }
  let!(:account)        { project.account }
  let!(:user_to_remove) { Fabricate(:user) }
  let!(:user_to_add)    { Fabricate(:user) }
  let!(:admin)          { Fabricate(:user) }

  before do
    membership_to_remove =
      Fabricate(:membership, account: account, user: user_to_remove)
    membership_to_add =
      Fabricate(:membership, account: account, user: user_to_add)
    admin_membership =
      Fabricate(:membership, account: account, user: admin, admin: true)

    Fabricate(:permission, membership: membership_to_remove, project: project)

    project.reload
    project.user_ids = [user_to_add.id, ""]
    project.save!
  end

  it "adds an added user" do
    expect(user_to_add).to be_member_of(project)
  end

  it "removes a removed user" do
    expect(user_to_remove).not_to be_member_of(project)
  end

  it "keeps an admin" do
    expect(admin).to be_member_of(project)
  end
end

describe Project, "assigning users on create" do
  let!(:project) { Fabricate.build(:project) }
  let!(:account) { project.account = Fabricate(:account) }
  let!(:member)  { Fabricate(:user) }
  let!(:admin)   { Fabricate(:user) }

  before do
    Fabricate(:membership, account: account, user: member)
    Fabricate(:membership, account: account, user: admin, admin: true)
    project.save!
  end

  it "adds admins to the project" do
    expect(admin).to be_member_of(project)
  end

  it "ignores normal users" do
    expect(member).not_to be_member_of(project)
  end
end
# TODO: Maybe test for upgrading users to  admins
