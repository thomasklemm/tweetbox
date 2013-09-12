# The Registration class is a form object class that helps with
# creating a user and allows for a customized registration and
# registration upon invitation process
#
# Example:
#   Registration.new(
#     first_name: 'Thomas',
#     last_name: 'Klemm',
#     email: 'thomas@tklemm.eu',
#     password: '123123123',
#     invitation_code: '123abc123abc')
#
class Registration
  include Reformer

  attr_reader :user
  attr_reader :invitation
  attr_reader :membership

  attribute :first_name, String
  attribute :last_name, String
  attribute :email, String
  attribute :password, String
  attribute :invitation_code, String # to add errors

  validates :first_name,
            :last_name,
            :email,
            :password, presence: true

  validate :invitation_must_be_present
  validate :invitation_must_not_be_used
  validate :invitation_must_not_be_expired

  def invitation_code=(code)
    @invitation = Invitation.where(code: code).first
  end

  def invitation_code
    @invitation.try(:code)
  end

  delegate :account, to: :invitation

  def save
    # Validate registration object
    return false unless valid?

    delegate_attributes_for_user
    delegate_errors_for_user unless @user.valid?

    # Have any errors been added by validating the user?
    if !errors.any?
      persist!
      true
    else
      false
    end
  end

  private

  ##
  # Create user

  def delegate_attributes_for_user
    @user = User.new do |user|
      user.first_name = first_name
      user.last_name = last_name
      user.email = email
      user.password = password
      user.password_confirmation = password
    end
  end

  def delegate_errors_for_user
    errors.add(:first_name, @user.errors[:first_name].try(:first))
    errors.add(:last_name, @user.errors[:last_name].try(:first))
    errors.add(:email, @user.errors[:email].try(:first))
    errors.add(:password, @user.errors[:password].try(:first))
  end

  def persist!
    @user.save!
    accept_invitation
    true
  end

  ##
  # Accept invitation

  def accept_invitation
    create_account_membership
    create_project_permissions
    mark_invitation_as_used
  end

  def create_account_membership
    @membership = Membership.create! do |membership|
      membership.user    = @user
      membership.account = invitation.account
      membership.admin   = false
    end
  end

  def create_project_permissions
    invitation.projects.each do |project|
      project.permissions.where(membership_id: @membership.id).first_or_create!
    end
  end

  def mark_invitation_as_used
    @invitation.use!(@user)
  end

  ##
  # Validations

  def invitation_must_be_present
    unless @invitation.present?
      errors.add(:invitation_code, 'is unknown')
    end
  end

  def invitation_must_not_be_used
    if @invitation.try(:used?)
      errors.add(:invitation_code, 'has already been used')
    end
  end

  def invitation_must_not_be_expired
    if @invitation.try(:expired?)
      errors.add(:invitation_code, 'has expired')
    end
  end
end
