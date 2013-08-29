class MailPreview < MailView
  def a_confirmation
    Devise::Mailer.confirmation_instructions(devise_user)
  end

  def b_reset_password
    Devise::Mailer.reset_password_instructions(devise_user)
  end

  def c_invitation
    account = Account.first
    invitation = account.invitations.create! do |i|
      i.name   = 'Philipp Thiel'
      i.email  = 'philipp@tweetbox.co'
      i.issuer = account.users.first
    end

    Mailer.invitation_instructions(invitation)
  end

  private

  def devise_user
    User.first.tap do |u|
      u.confirmation_token = random_token
      u.reset_password_token = random_token
    end
  end

  def random_token
    SecureRandom.hex(16/2)
  end
end
