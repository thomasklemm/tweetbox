# == Schema Information
#
# Table name: memberships
#
#  account_id :integer
#  admin      :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  updated_at :datetime         not null
#  user_id    :integer
#
# Indexes
#
#  index_memberships_on_user_id_and_account_id  (user_id,account_id) UNIQUE
#

require 'spec_helper'

describe Membership do
  subject { Fabricate(:membership) }
  it { should be_valid }

  it { should belong_to(:user) }
  it { should belong_to(:account) }

  it { should validate_presence_of(:user_id) }
  it { should validate_presence_of(:account_id) }
  it { should validate_uniqueness_of(:user_id).scoped_to(:account_id) }

  it { should have_many(:permissions).dependent(:destroy) }
  it { should have_many(:projects).through(:permissions) }

  let(:user)       { Fabricate(:user) }
  let(:membership) { Fabricate(:membership, user: user) }

  context "given an existing account membership" do
    before { Fabricate(:membership) }
    it { should validate_uniqueness_of(:user_id).scoped_to(:account_id) }
  end

  describe "delegates to user" do
    it { should respond_to(:name) }
    it { should respond_to(:email) }
  end

  it "returns memberships by name" do
    Fabricate(:membership, user: Fabricate(:user, name: 'def'))
    Fabricate(:membership, user: Fabricate(:user, name: 'abc'))
    Fabricate(:membership, user: Fabricate(:user, name: 'ghi'))

    expect(Membership.by_name.map(&:name)).to eq(%w(abc def ghi))
  end
end
