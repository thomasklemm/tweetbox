require 'spec_helper'

describe AccountPolicy do
  let(:account)  { Fabricate(:account) }
  let(:user)     { Fabricate(:user) }
  subject        { AccountPolicy }

  context 'user with admin membership' do
    before do
      Fabricate(:membership, user: user, account: account, admin: true)
    end

    it { should permit(user, account, :index?) }
    it { should permit(user, account, :show?) }
    it { should permit(user, account, :new?) }
    it { should permit(user, account, :create?) }
    it { should permit(user, account, :edit?) }
    it { should permit(user, account, :update?) }
    it { should permit(user, account, :destroy?) }
  end

  context 'user with non-admin membership' do
    before do
      Fabricate(:membership, user: user, account: account)
    end

    it { should permit(user, account, :index?) }
    it { should permit(user, account, :show?) }
    it { should permit(user, account, :new?) }
    it { should permit(user, account, :create?) }
    it { should_not permit(user, account, :edit?) }
    it { should_not permit(user, account, :update?) }
    it { should_not permit(user, account, :destroy?) }
  end
end
