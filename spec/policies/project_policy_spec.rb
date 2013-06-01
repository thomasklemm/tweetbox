require 'spec_helper'

describe ProjectPolicy do
  subject       { ProjectPolicy }

  let(:project) { Fabricate(:project) }

  let(:admin)   { Fabricate(:user) }
  let(:admin_membership) { Fabricate(:membership,
      user: admin, account: project.account, admin: true)}
  let!(:admin_permission) { Fabricate(:permission,
      membership: admin_membership, project: project) }

  let(:user) { Fabricate(:user) }
  let(:user_membership) { Fabricate(:membership,
      user: user, account: project.account, admin: false)}
  let!(:user_permission) { Fabricate(:permission,
      membership: user_membership, project: project) }

  let(:other_project) { Fabricate(:project) }

  permissions :access? do
    it "grants admins and users with permission to access the project" do
      should permit(admin, project)
      should permit(user, project)
    end

    it "denies admins and users to access a project without any permissions" do
      should_not permit(admin, other_project)
      should_not permit(user, other_project)
    end
  end

  permissions :manage? do
    it "allows account admins to create, update and destroy projects" do
      should permit(admin, project)
      should_not permit(user, project)

      should_not permit(admin, other_project)
      should_not permit(user, other_project)
    end
  end
end

