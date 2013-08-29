class Mailer < ActionMailer::Base
  default from: "Tweetbox <tweetbox@tweetbox.co>"

  # Sends an invitation mail that allows new user
  # to register with the invitation token
  #
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.mailer.invitation_instructions.subject
  #
  def invitation_instructions(invitation)
    @invitation = invitation.decorate
    mail to: invitee_email(@invitation)
         # reply_to: @invitation.issuer_email
  end

  private

  def invitee_email(invitation)
    "#{invitation.name} <#{invitation.email}>"
  end
end
