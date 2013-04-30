# == Schema Information
#
# Table name: invitations
#
#  account_id :integer
#  admin      :boolean          default(FALSE), not null
#  code       :string(255)
#  created_at :datetime         not null
#  email      :string(255)
#  id         :integer          not null, primary key
#  invitee_id :integer
#  sender_id  :integer
#  updated_at :datetime         not null
#  used       :boolean          default(FALSE), not null
#
# Indexes
#
#  index_invitations_on_account_id  (account_id)
#

require 'spec_helper'

describe Invitation do
  subject(:invitation) { Fabricate.build(:invitation) }
  it { should be_valid }

  it { should belong_to(:account) }
  it { should belong_to(:sender).class_name('User') }
  it { should belong_to(:invitee).class_name('User') }
  it { should have_and_belong_to_many(:projects) }

  it { should validate_presence_of(:account) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:sender) }
  it { should validate_presence_of(:code) }
  it { should validate_uniqueness_of(:code) }

  it "generates code" do
    expect(invitation.code).to be_present
  end

  it "uses the code in the URL" do
    expect(invitation.to_param).to eq(invitation.code)
  end

  it "delegates sender name" do
    expect(invitation.sender_name).to eq(invitation.sender.name)
  end

  it "delegates sender email" do
    expect(invitation.sender_email).to eq(invitation.sender.email)
  end

  it "delegates account name" do
    expect(invitation.account_name).to eq(invitation.account.name)
  end

  describe "#send_mail!" do
    it "sends an invitation mail" do
      mail = stub('invitation_mail')
      mail.expects(:deliver).returns(true).once
      InvitationMailer.expects(:invitation).with(invitation).returns(mail).once

      invitation.send_mail!
    end
  end
end
