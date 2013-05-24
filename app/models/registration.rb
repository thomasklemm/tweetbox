# The Registration class is a form object class that helps with
# creating a user and allows for a customized registration and
# registration upon invitation process
class Registration
  include Reformer

  attr_reader :user

  attribute :name, String
  attribute :email, String
  attribute :password, String

  validates :name, :email, :password, presence: true

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

  def delegate_attributes_for_user
    @user = User.new do |user|
      user.name = name
      user.email = email
      user.password = password
      user.password_confirmation = password
    end
  end

  def delegate_errors_for_user
    errors.add(:name, @user.errors[:name].try(:first))
    errors.add(:email, @user.errors[:email].try(:first))
    errors.add(:password, @user.errors[:password].try(:first))
  end

  def persist!
    @user.save!
  end
end
