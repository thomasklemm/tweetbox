# The signup class is a form object class that helps with
# creating a user, account and project all in one step and form
class Signup
  include Virtus

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_reader :user
  attr_reader :account
  attr_reader :membership
  attr_reader :project

  attribute :name, String
  attribute :company_name, String
  attribute :email, String
  attribute :password, String

  validates :name, :company_name, :email, :password, presence: true

  # Forms are never themselves persisted
  def persisted?
    false
  end

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
      account.plan = trial_plan
    end
  end

  def delegate_errors_for_user
    name_error = @user.errors[:name]
    email_error = @user.errors[:email]
    password_error = @user.errors[:password]
    @user.errors.clear

    errors.add(:name, name_error) if name_error.present?
    errors.add(:email, email_error) if email_error.present?
    errors.add(:password, password_error) if password_error.present?
  end

  def delegate_errors_for_account
    name_error = @account.errors[:name]
    @account.errors.clear

    errors.add(:company_name, name_error) if name_error.present?
  end

  def persist!
    @user.save!
    @account.save!

    create_admin_membership
    create_project
  end

  def create_admin_membership
    @membership = Membership.create! do |membership|
      membership.user = @user
      membership.account = @account
      membership.admin = true
    end
  end

  def create_project
    @project = @account.projects.create! do |project|
      project.name = @account.name
    end
  end

  # Assign the trial plan to the created account
  def trial_plan
    !Rails.env.test? ? Plan.trial : Fabricate(:trial_plan)
  end
end
