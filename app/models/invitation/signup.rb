class Invitation::Signup
  include Virtus

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attribute :name, String
  attribute :email, String
  attribute :password, String
  validates :name, :email, :password, presence: true

  attr_reader :user
  attr_reader :membership

  attribute :invitation, Invitation
  validates :invitation, presence: true

  # Forms are never themselves persisted
  def persisted?
    false
  end

  def save
    # Validate signup object
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

  def persist!
    @user.save!

    create_membership
    set_used_flag_on_invitation
  end

  def create_membership
    @membership = invitation.account.memberships.where(user_id: @user.id).first_or_initialize

    @membership.admin = invitation.admin?
    @membership.save!
  end

  def set_used_flag_on_invitation
    invitation.update_column(used: true)
  end
end
