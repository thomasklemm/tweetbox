# == Schema Information
#
# Table name: projects
#
#  account_id                 :integer          not null
#  created_at                 :datetime         not null
#  default_twitter_account_id :integer
#  id                         :integer          not null, primary key
#  name                       :text             not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_projects_on_account_id  (account_id)
#

require 'spec_helper'

describe Project do
  subject(:project) { Fabricate.build(:project) }
  it { should be_valid }

  it { should belong_to(:account) }

  it { should have_many(:permissions) }
  it { should have_many(:memberships).through(:permissions) }
  it { should have_many(:users).through(:permissions) }

  it { should have_many(:twitter_accounts).dependent(:destroy) }
  it { should belong_to(:default_twitter_account) }

  it { should have_many(:searches) }

  it { should have_many(:tweets).dependent(:destroy) }
  it { should have_many(:authors).dependent(:destroy) }

  it { should validate_presence_of(:account) }
  it { should validate_presence_of(:name) }

  describe ".by_name" do
    it "returns projects by name" do
      Fabricate(:project, name: 'def')
      Fabricate(:project, name: 'abc')
      Fabricate(:project, name: 'ghi')

      expect(Project.by_name.map(&:name)).to eq(%w(abc def ghi))
    end
  end

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
    let(:membership) { Fabricate(:membership, account: project.account, user: user) }

    context "with permission" do
      let!(:permission) { Fabricate(:permission, project: project, membership: membership) }
      it { should have_member(user) }
    end

    context "without permission" do
      before { membership.save }
      it { should_not have_member(user) }
    end
  end

  describe "#to_param" do
    it "includes the id and name" do
      project.name = "Tweetbox Project"
      project.save

      expect(project.to_param).to eq("#{ project.id }-tweetbox-project")
    end
  end

  describe "#create_tweets_from_twitter" do
    pending
  end

  describe "#create_tweet_from_twitter" do
    pending
  end

  describe "#find_or_fetch_tweet" do
    pending
  end
end
