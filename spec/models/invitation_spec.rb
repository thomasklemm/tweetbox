# == Schema Information
#
# Table name: invitations
#
#  account_id :integer          not null
#  code       :text             not null
#  created_at :datetime         not null
#  email      :text
#  expires_at :datetime
#  id         :integer          not null, primary key
#  invitee_id :integer
#  issuer_id  :integer          not null
#  name       :text
#  updated_at :datetime         not null
#  used_at    :datetime
#
# Indexes
#
#  index_invitations_on_account_id  (account_id)
#  index_invitations_on_code        (code) UNIQUE
#

require 'spec_helper'

describe Invitation do
  subject(:invitation) { Fabricate.build(:invitation) }
  it { should be_valid }

  it { should belong_to(:account) }
  it { should belong_to(:issuer).class_name('User') }
  it { should belong_to(:invitee).class_name('User') }

  it { should have_many(:invitation_projects).dependent(:destroy) }
  it { should have_many(:projects).through(:invitation_projects) }

  it { should validate_presence_of(:account) }
  it { should validate_presence_of(:issuer) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:code) }

  context "saved invitation" do
    before { invitation.save }
    it { should validate_uniqueness_of(:code) }
  end

  describe "callbacks" do
    describe "#generate_code after initialization" do
      it "generates invitation code" do
        expect(invitation.code).to be_present
        expect(invitation.code.length).to be(32)
      end

      it "persists the invitation code in the database and does not change it on reloading the record" do
        code = invitation.code
        invitation.save
        invitation.reload
        expect(invitation.code).to eq(code)
      end
    end

    describe "#set_expiration_date before create" do
      pending
    end
  end

  describe "#active?" do
    pending
  end

  describe "#expired?" do
    pending
  end

  describe "#used?" do
    pending
  end

  describe "#use!" do
    pending
  end

  describe "#deactivate!" do
    pending
  end

  describe "#reactivate!" do
    pending
  end

  describe "#to_param" do
    it "prints the code as URL param" do
      expect(invitation.to_param).to eq(invitation.code)
    end
  end

  describe "#deliver_mail" do
    it "sends an invitation mail" do
      mail = stub('invitation_mail')
      mail.expects(:deliver).returns(true).once
      InvitationMailer.expects(:invitation).with(invitation).returns(mail).once

      invitation.deliver_mail
    end
  end
end
