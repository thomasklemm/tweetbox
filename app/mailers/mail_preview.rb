class MailPreview < MailView
  def confirmation
    user = User.first
    user.confirmation_token = SecureRandom.hex(16/2)

    Devise::Mailer.confirmation_instructions(user)
  end
end
