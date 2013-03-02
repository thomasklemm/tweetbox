class AccountPolicy < ApplicationPolicy
  alias_method :account, :record

  def admin_action
    user.admin_of?(account)
  end

  def member_action
    user.member_of?(account)
  end

  def new?
    create?
  end

  # Any signed in user can create a project
  def create?
    user.present?
  end

  alias_method :show?,   :member_action

  alias_method :update?,  :admin_action
  alias_method :edit?,    :admin_action
  alias_method :destroy?, :admin_action
end