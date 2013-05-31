class ProjectPolicy < ApplicationPolicy
  alias_method :project, :record

  def access?
    user.member_of?(project)
  end

  def admin_action
    user.admin_of?(project.account)
  end

  alias_method :create?,  :admin_action
  alias_method :update?,  :admin_action
  alias_method :destroy?, :admin_action
end
