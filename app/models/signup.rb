# The signup class is a form object class that helps with
# creating a user, account and project all in one step and form
class Signup
  include FormObject

  attr_reader :user
  attr_reader :account
  attr_reader :membership
  attr_reader :project

  attribute :name, String
  attribute :company_name, String
  attribute :email, String
  attribute :password, String

  validates :name, :company_name, :email, :password, presence: true

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
      user.name = name
      user.email = email
      user.password = password
      user.password_confirmation = password
    end
  end

  def delegate_attributes_for_account
    @account = Account.new do |account|
      account.name = company_name
      account.plan = Plan.trial
    end
  end

  def delegate_errors_for_user
    errors.add(:name, @user.errors[:name].first) if @user.errors[:name].present?
    errors.add(:email, @user.errors[:email].first) if @user.errors[:email].present?
    errors.add(:password, @user.errors[:password].first) if @user.errors[:password].present?
  end

  def delegate_errors_for_account
    errors.add(:company_name, @account.errors[:name].first) if @account.errors[:name].present?
  end

  def persist!
    @user.save!
    @account.save!

    create_admin_membership!
    create_project!
  end

  def create_admin_membership!
    @membership = Membership.create! do |membership|
      membership.user = @user
      membership.account = @account
      membership.admin = true
    end
  end

  def create_project!
    @project = @account.projects.create! do |project|
      project.name = @account.name
    end
  end
end
