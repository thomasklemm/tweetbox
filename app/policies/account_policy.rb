class AccountPolicy < ApplicationPolicy
  def account
    record
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    true
  end

  def new?
    create?
  end

  def update?
    user.admin_of?(account)
  end

  def edit?
    update?
  end

  def destroy?
    user.admin_of?(account)
  end
end
