require 'spec_helper'

describe ProjectPolicy do
  let(:account)  { Fabricate(:account) }
  let(:user)     { Fabricate(:user) }
  let(:project)  { Fabricate(:project, account: account)}
  subject        { ProjectPolicy }

  context 'for admin of project-owning account' do
    before do
      Fabricate(:membership, user: user, account: account, admin: true)
    end

    it { should permit(user, project, :index?) }
    it { should permit(user, project, :show?) }
    it { should permit(user, project, :new?) }
    it { should permit(user, project, :create?) }
    it { should permit(user, project, :edit?) }
    it { should permit(user, project, :update?) }
    it { should permit(user, project, :destroy?) }
  end

  context 'for non-admin of project-owning account' do
    before do
      Fabricate(:membership, user: user, account: account, admin: false)
    end

    it { should permit(user, project, :index?) }
    it { should permit(user, project, :show?) }
    it { should_not permit(user, project, :new?) }
    it { should_not permit(user, project, :create?) }
    it { should_not permit(user, project, :edit?) }
    it { should_not permit(user, project, :update?) }
    it { should_not permit(user, project, :destroy?) }
  end
end
