# The InvitationSignup class is a form object class that helps with
# creating a user and accepting an invitation.
class InvitationSignup
  include Virtus

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :invitation
  validates :invitation, presence: true

  # User
  attr_accessor :user
  validates :user, presence: true

  # New user
  attribute :name, String
  attribute :email, String
  attribute :password, String

  # Membership
  attr_reader :membership

  def initialize(code)
    @invitation = Invitation.where(code: code).first
  end

  # Forms are never themselves persisted
  def persisted?
    false
  end

  def code
    @invitation.try(:code)
  end

  def account
    @invitation.try(:account)
  end

  def projects
    @invitation.try(:projects)
  end

  def save
    # Use existing user provided from the current_user in the controller
    # or create a new user
    @user ||= build_new_user

    # Validate presence of user and invitation
    return false unless valid?

    @user.valid? or delegate_errors_for_user

    # Have any errors been added by validating the user?
    if !errors.any?
      persist!
      true
    else
      false
    end

  end

  private

  def build_new_user
    @user = User.new do |user|
      user.name = name
      user.email = email
      user.password = password
      user.password_confirmation = password
    end
  end

  def delegate_errors_for_user
    errors.add(:name, @user.errors[:name]) if @user.errors[:name].present?
    errors.add(:email, @user.errors[:email]) if @user.errors[:email].present?
    errors.add(:password, @user.errors[:password]) if @user.errors[:password].present?
    @user.errors.clear
  end

  def persist!
    @user.save!

    create_membership
    create_permissions

    mark_invitation_as_used
  end

  def create_membership
    # Invitation can be used to upgrade a user to admin
    # or create a new membership
    @membership = account.memberships.where(user_id: @user.id).first_or_initialize

    # Mark as admin dependent on invitation
    @membership.admin = @invitation.admin
    @membership.save!
  end

  def create_permissions
    projects.each do |project|
      @membership.projects << project
    end

    # TODO: If admin add to all projects
  end

  def mark_invitation_as_used
    @invitation.used = true
    @invitation.save
  end
end
