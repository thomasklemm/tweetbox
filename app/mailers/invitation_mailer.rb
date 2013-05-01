class InvitationMailer < ActionMailer::Base
  # Send out a mail with a link that allows new users
  # to accept an invitation
  def invitation(invitation)
    @invitation = invitation

    mail from: mail_from,
         to: @invitation.email,
         subject: mail_subject,
         reply_to: InvitationMailer.support_email
  end

  private

  def mail_subject
    "#{ @invitation.sender_name } has invited you to join Birdview."
  end

  def mail_from
    "#{ @invitation.sender_name } <#{ InvitationMailer.support_email }>"
  end

  def self.support_email
    'support@birdviewapp.com'
  end
end
