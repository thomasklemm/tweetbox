# == Schema Information
#
# Table name: users
#
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

describe User do
  subject(:user) { Fabricate.build(:user) }
  it { should be_valid }

  it { should have_one(:membership) }
  it { should have_one(:account).through(:membership) }

  it { should have_many(:permissions) }
  it { should have_many(:projects).through(:permissions) }

  it { should validate_presence_of(:name) }

  # Added by Devise
  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email) }
  it { should validate_presence_of(:password) }

  describe "#password" do
    it "ensures password length" do
      user = Fabricate.build(:user, password: '0' * 7)
      expect(user).to have(2).errors_on(:password)
      expect(user.errors_on(:password).uniq.length).to eq(1)
      expect(user.errors_on(:password)).to include("is too short (minimum is 8 characters)")

      user = Fabricate.build(:user, password: '0' * 8)
      expect(user).to be_valid

      user = Fabricate.build(:user, password: '0' * 128)
      expect(user).to be_valid

      user = Fabricate.build(:user, password: '0' * 129)
      expect(user).to have(2).errors_on(:password)
      expect(user.errors_on(:password).uniq.length).to eq(1)
      expect(user.errors_on(:password)).to include("is too long (maximum is 128 characters)")
    end
  end
  # TODO: Should not be confirmed at first, but when timestamp is set
end

describe User, 'persisted' do
  subject(:user) { Fabricate(:user) }
  it { should be_valid }

  let(:account) { Fabricate(:account) }
  let(:other_user) { Fabricate(:user) }
  let(:other_account) { Fabricate(:account) }

  let(:project) { Fabricate(:project, account: account) }
  let(:other_project) { Fabricate(:project, account: account) }

  describe "#to_param" do
    it "returns includes the id and name" do
      expect(user.to_param).to match(%r{\d+\-\w+})
      expect(user.to_param).to eq("#{ user.id }-#{ user.name.parameterize }")
    end
  end

  describe "#admin_of?(account)" do
    context "with admin account membership" do
      let!(:admin_membership) { Fabricate(:membership, account: account, user: user, admin: true) }

      it "returns true" do
        expect(user).to be_admin_of(account)
      end
    end

    context "with non-admin account membership" do
      let!(:membership) { Fabricate(:membership, account: account, user: user, admin: false) }

      it "returns false" do
        expect(user).to_not be_admin_of(account)
      end
    end

    context "without account membership" do
      before { Fabricate(:membership, account: account, user: user, admin: true) }

      it "returns false" do
        expect(other_user).to_not be_admin_of(account)
      end
    end
  end

  describe "#member_of?(account_or_project)" do
    context "with admin account membership" do
      let!(:admin_membership) { Fabricate(:membership, account: account, user: user, admin: true) }

      it "returns true" do
        expect(user).to be_member_of(account)
      end
    end

    context "with non-admin account membership" do
      let!(:membership) { Fabricate(:membership, account: account, user: user, admin: false) }

      it "returns true" do
        expect(user).to be_member_of(account)
      end
    end

    context "without account membership" do
      before { Fabricate(:membership, account: account, user: user, admin: true) }

      it "returns false" do
        expect(other_user).to_not be_member_of(account)
      end
    end

    context "with account membership" do
    let!(:membership) { Fabricate(:membership, account: account, user: user, admin: false) }

      context "with project permission" do
        let!(:permission) { Fabricate(:permission, project: project, user: user) }

        it "returns true" do
          expect(user).to be_member_of(project)
        end
      end

      context "without project permission" do
        let!(:other_permission) { Fabricate(:permission, project: other_project, user: user) }

        it "returns false" do
          expect(user).to_not be_member_of(project)
        end
      end
    end
  end
end
