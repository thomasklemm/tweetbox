class ProjectPolicy < ApplicationPolicy
  alias_method :project, :record

  def admin_action
    user.admin_of?(project.account)
  end

  def member_action
    user.member_of?(project)
  end

  alias_method :index?,  :member_action
  alias_method :show?,   :member_action

  alias_method :new?,     :admin_action
  alias_method :create?,  :admin_action
  alias_method :update?,  :admin_action
  alias_method :edit?,    :admin_action
  alias_method :destroy?, :admin_action
end
