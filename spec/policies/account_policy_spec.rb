require 'spec_helper'

describe AccountPolicy do
  subject { AccountPolicy }

  let(:admin)   { Fabricate(:user) }
  let(:user)    { Fabricate(:user) }
  let(:account) { Fabricate(:account) }
  let(:other_account) { Fabricate(:account) }

  let!(:admin_membership) { Fabricate(:membership, user: admin, account: account, admin: true) }
  let!(:membership) { Fabricate(:membership, user: user, account: account) }

  permissions :access? do
    it "grants users on the account with admin membership access" do
      should permit(admin, account)
    end

    it "denies user on the account to access the account without admin membership" do
      should_not permit(user, account)
    end

    it "denies users access to other accounts where there is no membership" do
      should_not permit(admin, other_account)
      should_not permit(user, other_account)
    end
  end
end
