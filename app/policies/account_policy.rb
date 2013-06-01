class AccountPolicy < ApplicationPolicy
  alias_method :account, :record

  def manage?
    user.admin_of?(account)
  end
end
