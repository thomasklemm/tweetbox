require 'spec_helper'

describe AccountPolicy do
  subject        { AccountPolicy }
  let(:account)  { Fabricate(:account) }

  context 'for account admin' do
    let(:admin)       { Fabricate(:user) }
    let!(:membership) { Fabricate(:membership,
      user: admin, account: account, admin: true) }

    it { should permit(admin, account, :show?) }
    it { should permit(admin, account, :new?) }
    it { should permit(admin, account, :create?) }
    it { should permit(admin, account, :edit?) }
    it { should permit(admin, account, :update?) }
    it { should permit(admin, account, :destroy?) }
  end

  context 'for account member' do
    let(:member)      { Fabricate(:user) }
    let!(:membership) { Fabricate(:membership,
      user: member, account: account) }

    it { should permit(member, account, :show?) }
    it { should permit(member, account, :new?) }
    it { should permit(member, account, :create?) }
    it { should_not permit(member, account, :edit?) }
    it { should_not permit(member, account, :update?) }
    it { should_not permit(member, account, :destroy?) }
  end

  context 'for other user' do
    let(:non_member)      { Fabricate(:user) }
    let(:other_account)   { Fabricate(:account) }
    let!(:non_membership) { Fabricate(:membership,
      user: non_member, account: other_account, admin: true) }

    it { should_not permit(non_member, account, :show?) }
    it { should_not permit(non_member, account, :new?) }
    it { should_not permit(non_member, account, :create?) }
    it { should_not permit(non_member, account, :edit?) }
    it { should_not permit(non_member, account, :update?) }
    it { should_not permit(non_member, account, :destroy?) }
  end
end
