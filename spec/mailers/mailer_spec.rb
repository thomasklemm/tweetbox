require "spec_helper"

describe Mailer do
  describe "invitation_instructions" do
    let(:mail) { Mailer.invitation_instructions }

    it "renders the headers" do
      mail.subject.should eq("Invitation instructions")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

end
