class Invitation::Registration < Invitation::Base
  attribute :name, String
  attribute :email, String
  attribute :password, String

  def save
    delegate_attributes_for_user
    user.valid? or delegate_errors_for_user

    if errors.empty? && valid?
      user.save!
      persist!
      true
    else
      false
    end
  end

  private

  def delegate_attributes_for_user
    self.user = User.new do |u|
      u.name = name
      u.email = email
      u.password = password
      u.password_confirmation = password
    end
  end

  def delegate_errors_for_user
    errors.add(:name, user.errors[:name].first) if user.errors[:name].present?
    errors.add(:email, user.errors[:email].first) if user.errors[:email].present?
    errors.add(:password, user.errors[:password].first) if user.errors[:password].present?
  end
end
