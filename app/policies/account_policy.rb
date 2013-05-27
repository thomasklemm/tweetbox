class AccountPolicy < ApplicationPolicy
  alias_method :account, :record

  def admin_action
    user.admin_of?(account)
  end

  def member_action
    user.member_of?(account)
  end

  # Any signed in user can create an account
  def create?
    true
  end
  alias_method :new?, :create?

  alias_method :show?,   :member_action

  alias_method :update?,  :admin_action
  alias_method :edit?,    :admin_action
  alias_method :destroy?, :admin_action

  # Can a user invite someone to the account?
  alias_method :invite?,  :admin_action
end
