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
  subject { Fabricate.build(:invitation) }
  it { should be_valid }

  it { should belong_to(:account) }
  it { should belong_to(:sender).class_name('User') }
  it { should have_and_belong_to_many(:projects) }

  it { should validate_presence_of(:account) }
  it { should validate_presence_of(:email) }

  it "generates code" do
    expect(subject.code).to be_present
  end

  it "uses the code in the URL" do
    expect(subject.to_param).to eq(subject.code)
  end

  it "delegates sender name" do
    expect(subject.sender_name).to eq(subject.sender.name)
  end

  it "delegates sender email" do
    expect(subject.sender_email).to eq(subject.sender.email)
  end

  it "delegates account name" do
    expect(subject.account_name).to eq(subject.account.name)
  end

  describe "#send_email" do
    it "sends an invitation email" do
      mail = stub('invitation_mail', deliver: true)
      InvitationMailer.stubs(:invitation).returns(mail)

      subject.send_email

      expect(InvitationMailer).to have_received(:invitation).with(subject).once
      expect(mail).to have_received(:deliver).once
    end
  end
end
