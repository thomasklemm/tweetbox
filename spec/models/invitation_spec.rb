# == Schema Information
#
# Table name: invitations
#
#  account_id :integer
#  admin      :boolean          default(FALSE), not null
#  code       :string(255)      not null
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

  it "generates invitation code after initialization" do
    expect(invitation.code).to be_present
  end

  it "persists the invitation code in the database" do
    code = invitation.code
    invitation.save
    invitation.reload
    expect(invitation.code).to eq(code)
  end

  it "prints the code as URL param" do
    expect(invitation.to_param).to eq(invitation.code)
  end

  it "delegates account name" do
    expect(invitation.account_name).to eq(invitation.account.name)
  end

  it "delegates sender name" do
    expect(invitation.sender_name).to eq(invitation.sender.name)
  end

  describe "#active?" do
    it "returns true when new record" do
      expect(invitation).to be_new_record
      expect(invitation).to be_active
    end

    it "returns true when the invitation is less than seven days old" do
      Timecop.freeze
      invitation.created_at = 7.days.ago - 1.second
      invitation.save
      expect(invitation).to be_active
      Timecop.return
    end

    it "returns false when the invitation is more than seven days old" do
      Timecop.freeze
      invitation.created_at = 7.days.ago + 1.second
      invitation.save
      expect(invitation).to_not be_active
      Timecop.return
    end
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
