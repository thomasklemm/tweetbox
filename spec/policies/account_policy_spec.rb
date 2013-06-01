require 'spec_helper'

describe AccountPolicy do
  subject { AccountPolicy }

  let(:admin)   { Fabricate(:user) }
  let(:user)    { Fabricate(:user) }
  let(:account) { Fabricate(:account) }
  let(:other_account) { Fabricate(:account) }

  let!(:admin_membership) { Fabricate(:membership, user: admin, account: account, admin: true) }
  let!(:membership) { Fabricate(:membership, user: user, account: account) }

  permissions :manage? do
    it "permits account admins to manage the account" do
      should permit(admin, account)
    end

    it "forbids account members without admin status to manage the account" do
      should_not permit(user, account)
    end

    it "forbids account admins and members to manage other accounts" do
      should_not permit(admin, other_account)
      should_not permit(user, other_account)
    end
  end
end
