require "spec_helper"

describe Mailer, "invitation" do
  describe "#invitation_instructions" do
    let(:invitation) { Fabricate(:invitation, email: 'philipp@tweetbox.co', name: 'Philipp Thiel').decorate }
    let(:mail) { Mailer.invitation_instructions(invitation) }

    it "renders the headers" do
      expect(mail.subject).to eq("An invitation to Tweetbox - Twitter for Business")
      expect(mail.to).to eq(['philipp@tweetbox.co'])
      expect(mail.from).to eq(['tweetbox@tweetbox.co'])
      expect(mail.reply_to).to be_nil
    end

    it "renderes the body" do
      body = mail.body.encoded

      # invitation code
      expect(body).to include(invitation.registration_url)
    end
  end
end
