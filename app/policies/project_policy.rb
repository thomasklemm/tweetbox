class ProjectPolicy < ApplicationPolicy
  def project
    record
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.admin_of?(project.account)
  end

  def new?
    create?
  end

  def update?
    user.admin_of?(project.account)
  end

  def edit?
    update?
  end

  def destroy?
    user.admin_of?(project.account)
  end
end
