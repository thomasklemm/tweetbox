class Invitation::Signup
  include FormObject

  attribute :invitation, Invitation
  validates :invitation, presence: true

  attribute :name, String
  attribute :email, String
  attribute :password, String
  validates :name, :email, :password, presence: true

  attr_reader :user
  attr_reader :membership

  def code
    invitation.try(:code)
  end

  def code=(new_code)
    self.invitation = Invitation.find_by_code!(new_code)
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
    mark_invitation_as_used
  end

  def delegate_attributes_for_user
    @user = User.new do |user|
      user.name = name
      user.email = email
      user.password = password
      user.password_confirmation = password
    end
  end

  def delegate_errors_for_user
    errors.add(:name, @user.errors[:name].first) if @user.errors[:name].present?
    errors.add(:email, @user.errors[:email].first) if @user.errors[:email].present?
    errors.add(:password, @user.errors[:password].first) if @user.errors[:password].present?
  end

  def create_membership
    @membership = invitation.account.memberships.create! do |membership|
      membership.user = @user
      membership.admin = invitation.admin
    end
  end

  def mark_invitation_as_used
    invitation.update_attributes(used: true) # invokes callbacks
  end
end
