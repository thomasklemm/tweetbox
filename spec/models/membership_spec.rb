# == Schema Information
#
# Table name: memberships
#
#  account_id :integer          not null
#  admin      :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  updated_at :datetime         not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_memberships_on_user_id_and_account_id  (user_id,account_id) UNIQUE
#

require 'spec_helper'

describe Membership do
  subject(:membership) { Fabricate.build(:membership) }
  it { should be_valid }

  it { should belong_to(:user) }
  it { should belong_to(:account) }

  it { should have_many(:permissions).dependent(:destroy) }
  it { should have_many(:projects).through(:permissions) }

  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:account) }

  context "saved record" do
    before { membership.save }
    it { should validate_uniqueness_of(:user_id).scoped_to(:account_id) }
  end

  describe "#admin" do
    it "defaults to non-admin membership" do
      expect(membership).to_not be_admin
    end
  end

  describe "#admin!" do
    before { membership.save }

    it "marks a membership as an admin membership" do
      membership.admin!
      membership.reload
      expect(membership).to be_admin
    end
  end
end
