# The signup class is a form object class that helps with
# creating a user, account and project all in one step and form
class Signup
  include Reformer

  attr_reader :user
  attr_reader :account
  attr_reader :membership
  attr_reader :project
  attr_reader :permission

  attribute :first_name, String
  attribute :last_name, String
  attribute :company_name, String
  attribute :email, String
  attribute :password, String

  validates :first_name, :last_name, :company_name, :email, :password, presence: true

  def save
    # Validate signup object
    return false unless valid?

    delegate_attributes_for_user
    delegate_attributes_for_account

    delegate_errors_for_user unless @user.valid?
    delegate_errors_for_account unless @account.valid?

    # Have any errors been added by validating user and account?
    if !errors.any?
      persist!
      true
    else
      false
    end
  end

  private

  def delegate_attributes_for_user
    @user = User.new do |user|
      user.first_name            = first_name
      user.last_name             = last_name
      user.email                 = email
      user.password              = password
      user.password_confirmation = password
    end
  end

  def delegate_attributes_for_account
    @account = Account.new do |account|
      account.name = company_name
    end
  end

  def delegate_errors_for_user
    errors.add(:first_name, @user.errors[:first_name].try(:first))
    errors.add(:last_name, @user.errors[:last_name].try(:first))
    errors.add(:email, @user.errors[:email].try(:first))
    errors.add(:password, @user.errors[:password].try(:first))
  end

  def delegate_errors_for_account
    errors.add(:company_name, @account.errors[:name].try(:first))
  end

  def persist!
    @user.save!
    @account.save!

    create_admin_membership!
    create_project!
    create_permission!
  end

  def create_admin_membership!
    @membership = Membership.create! do |membership|
      membership.user    = @user
      membership.account = @account
      membership.admin   = true
    end
  end

  def create_project!
    @project = @account.projects.create! do |project|
      project.name = @account.name
    end
  end

  def create_permission!
    @permission = @project.permissions.create!(membership: @membership)
  end
end
