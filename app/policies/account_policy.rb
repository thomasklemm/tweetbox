class AccountPolicy < ApplicationPolicy
  alias_method :account, :record

  def access?
    user.admin_of?(account)
  end
end
