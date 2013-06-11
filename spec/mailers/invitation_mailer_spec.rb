require "spec_helper"

describe InvitationMailer, "invitation" do
  let(:invitation) { Fabricate(:invitation) }
  let(:mail) { InvitationMailer.invitation(invitation) }

  it "sets from to the user's name" do
    from_name = mail.header_fields.find { |field| field.name == "From" }
    expect(from_name.value).to match(%r{#{ invitation.sender_name } <.*>$})
  end

  it "sends from the support address" do
    expect(mail.from).to eq([InvitationMailer.support_email])
  end

  it "sends to the invitation email" do
    expect(mail.to).to eq([invitation.email])
  end

  it "sets the subject" do
    expect(mail.subject).to eq("#{ invitation.sender_name } has invited you to join Tweetbox.")
  end

  it "sets reply_to to the user that sent the invitation" do
    expect(mail.reply_to).to eq([InvitationMailer.support_email])
  end

  it "includes the invitation code in the body" do
    body = mail.body.encoded
    expect(body).to include(accept_invitation_url(invitation_code: invitation.code))
  end
end
