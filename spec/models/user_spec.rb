# == Schema Information
#
# Table name: users
#
#  active                 :boolean          default(TRUE)
#  confirmation_sent_at   :datetime
#  confirmation_token     :text
#  confirmed_at           :datetime
#  created_at             :datetime         not null
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :text
#  email                  :text             default(""), not null
#  encrypted_password     :text             default(""), not null
#  id                     :integer          not null, primary key
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :text
#  name                   :text             default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :text
#  sign_in_count          :integer          default(0)
#  unconfirmed_email      :text
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

require 'spec_helper'

describe User, "valid" do
  subject { Fabricate(:user) }
  it { should be_valid }

  it { should have_many(:memberships) }
  it { should have_many(:accounts).through(:memberships) }

  it { should have_many(:permissions) }
  it { should have_many(:projects).through(:permissions) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email) }
  it { should validate_presence_of(:password) }

  let(:account) { Fabricate(:account) }

  it "is an admin of an account with admin membership" do
    Fabricate(:membership, user: subject, account: account, admin: true)
    expect(subject).to be_admin_of(account)

    expect(subject.memberships.admin.first.account).to eq(account)
  end

  it "isn't an admin of an account with a non admin membership" do
    Fabricate(:membership, user: subject, account: account, admin: false)
    expect(subject).not_to be_admin_of(account)
  end

  it "isn't an admin of an account without a membership" do
    expect(subject).not_to be_admin_of(account)
  end

  it "is a member with a membership for the given account" do
    Fabricate(:membership, user: subject, account: account)
    expect(subject).to be_member_of(account)
  end

  it "isn't a member without a membership for the given account" do
    other_account = Fabricate(:account)
    Fabricate(:membership, user: subject, account: other_account)
    expect(subject).not_to be_member_of(account)
    expect(subject).to be_member_of(other_account)
  end

  let(:project) { Fabricate(:project) }

  it "is a member with a membership for the given project" do
    membership = Fabricate(:membership, user: subject, account: project.account)
    Fabricate(:permission, membership: membership, project: project)
    expect(subject).to be_member_of(project)
  end

  it "isn't a member without a membership for the given project" do
    other_project = Fabricate(:project)
    membership = Fabricate(:membership, user: subject, account: other_project.account)
    Fabricate(:permission, membership: membership, project: other_project)
    expect(subject).not_to be_member_of(project)
  end

  it "returns users by name" do
    Fabricate(:user, name: 'def')
    Fabricate(:user, name: 'abc')
    Fabricate(:user, name: 'ghi')

    expect(User.by_name.map(&:name)).to eq(%w(abc def ghi))
  end

  it "searches records for email and name" do
    email = Fabricate(:user, email: 'match@example.com')
    name  = Fabricate(:user, name: 'match max' )
    no_match = Fabricate(:user)

    expect(User.search('match')).to include(email)
    expect(User.search('match')).to include(name)
    expect(User.search('match')).not_to include(no_match)
  end

  it "return nothing for nil search" do
    expect(User.search(nil)).to eq([])
  end
end
