class InvitationMailer < ActionMailer::Base
  def invitation(invitation)
    @invitation = invitation
    mail to: invitation.email,
         subject: "Invitation",
         reply_to: invitation.sender_email,
         from: sender_name_and_support_email
  end

  private

  def sender_name_and_support_email
    "#{ @invitation.sender_name } <#{ InvitationMailer.support_email }>"
  end

  def self.support_email
    # TODO: Change support email
    "support@birdviewapp.com"
  end
end
