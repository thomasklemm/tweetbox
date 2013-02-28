class AccountPolicy < ApplicationPolicy
  alias_method :account, :record

  def admin_action
    user.admin_of?(account)
  end

  def member_action
    user.member_of?(account)
  end

  alias_method :index?,  :member_action
  alias_method :show?,   :member_action
  alias_method :new?,    :member_action
  alias_method :create?, :member_action

  alias_method :update?,  :admin_action
  alias_method :edit?,    :admin_action
  alias_method :destroy?, :admin_action
end
