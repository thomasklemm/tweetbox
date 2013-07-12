require 'spec_helper'

describe Project do
  subject(:project) { Fabricate.build(:project) }
  it { should be_valid }

  it { should belong_to(:account).counter_cache }

  it { should have_many(:permissions) }
  it { should have_many(:memberships).through(:permissions) }
  it { should have_many(:users).through(:permissions) }

  it { should have_many(:twitter_accounts).dependent(:destroy) }
  it { should belong_to(:default_twitter_account).class_name('TwitterAccount') }

  it { should have_many(:searches) }

  it { should have_many(:tweets).dependent(:destroy) }
  it { should have_many(:authors).dependent(:destroy) }

  it { should validate_presence_of(:account) }
  it { should validate_presence_of(:name) }
end

describe Project, 'persisted' do
  subject(:project) { Fabricate(:project) }
  it { should be_valid }

  describe ".visible_to(user)" do
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
  end

  describe "#has_member?" do
    let(:user) { Fabricate(:user) }
    let!(:membership) { Fabricate(:membership, account: project.account, user: user) }

    context "with permission" do
      let!(:permission) { Fabricate(:permission, project: project, membership: membership) }
      it "has member" do
        expect(project).to have_member(user)
      end
    end

    context "without permission" do
      it "does not have member" do
        expect(project).to_not have_member(user)
      end
    end
  end

  describe "#to_param" do
    it "returns includes the id and name" do
      expect(project.to_param).to match(%r{\d+\-\w+})
      expect(project.to_param).to eq("#{ project.id }-#{ project.name.parameterize }")
    end
  end
end
