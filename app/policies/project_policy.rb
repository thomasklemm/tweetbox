class ProjectPolicy < ApplicationPolicy
  alias_method :project, :record

  def member_action
    user.member_of?(project)
  end

  alias_method :access?, :member_action

  def admin_action
    user.admin_of?(project.account)
  end

  alias_method :new?,     :admin_action
  alias_method :create?,  :admin_action
  alias_method :edit?,    :admin_action
  alias_method :update?,  :admin_action
  alias_method :destroy?, :admin_action
end
