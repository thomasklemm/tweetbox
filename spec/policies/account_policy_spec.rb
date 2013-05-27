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
    it { should permit(admin, account) }
    it { should_not permit(user, account) }
    it { should_not permit(admin, other_account) }
    it { should_not permit(user, other_account) }
  end
end
