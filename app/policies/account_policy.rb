class AccountPolicy < ApplicationPolicy
  alias_method :account, :record

  def access?
    user.admin_of?(account)
  end

  alias_method :show?, :access?
  alias_method :update?, :access?
end
