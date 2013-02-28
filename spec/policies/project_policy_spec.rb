require 'spec_helper'

describe ProjectPolicy do
  subject       { ProjectPolicy }
  let(:project) { Fabricate(:project) }

  context 'account admin' do
    let(:admin)       { Fabricate(:user) }
    let(:membership)  { Fabricate(:membership,
      user: admin, account: project.account, admin: true)}
    let!(:permission) { Fabricate(:permission,
      membership: membership, project: project) }

    it { should permit(admin, project, :index?) }
    it { should permit(admin, project, :show?) }
    it { should permit(admin, project, :new?) }
    it { should permit(admin, project, :create?) }
    it { should permit(admin, project, :edit?) }
    it { should permit(admin, project, :update?) }
    it { should permit(admin, project, :destroy?) }
  end

  context 'account member with project permission' do
    let(:project_member) { Fabricate(:user) }
    let(:membership)     { Fabricate(:membership,
      user: project_member, account: project.account)}
    let!(:permission) { Fabricate(:permission,
      membership: membership, project: project) }

    it { should permit(project_member, project, :index?) }
    it { should permit(project_member, project, :show?) }
    it { should_not permit(project_member, project, :new?) }
    it { should_not permit(project_member, project, :create?) }
    it { should_not permit(project_member, project, :edit?) }
    it { should_not permit(project_member, project, :update?) }
    it { should_not permit(project_member, project, :destroy?) }
  end

  context 'account member without project permission' do
    let(:non_project_member) { Fabricate(:user) }
    let(:membership)         { Fabricate(:membership,
      user: non_project_member, account: project.account)}
    let(:other_project)      { Fabricate(:project) }
    let!(:permission) { Fabricate(:permission,
      membership: membership, project: other_project) }

    it { should_not permit(non_project_member, project, :index?) }
    it { should_not permit(non_project_member, project, :show?) }
    it { should_not permit(non_project_member, project, :new?) }
    it { should_not permit(non_project_member, project, :create?) }
    it { should_not permit(non_project_member, project, :edit?) }
    it { should_not permit(non_project_member, project, :update?) }
    it { should_not permit(non_project_member, project, :destroy?) }
  end

  context 'other user without account membership' do
    let(:other_user)    { Fabricate(:user) }
    let(:other_project) { Fabricate(:project) }
    let(:membership)    { Fabricate(:membership,
      user: other_user, account: other_project.account)}
    let!(:permission) { Fabricate(:permission,
      membership: membership, project: other_project) }

    it { should_not permit(other_user, project, :index?) }
    it { should_not permit(other_user, project, :show?) }
    it { should_not permit(other_user, project, :new?) }
    it { should_not permit(other_user, project, :create?) }
    it { should_not permit(other_user, project, :edit?) }
    it { should_not permit(other_user, project, :update?) }
    it { should_not permit(other_user, project, :destroy?) }
  end
end

