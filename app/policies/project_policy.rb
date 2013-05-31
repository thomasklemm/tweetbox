class ProjectPolicy < ApplicationPolicy
  alias_method :project, :record

  def access?
    user.member_of?(project)
  end

  def manage?
    user.admin_of?(project.account)
  end
end
