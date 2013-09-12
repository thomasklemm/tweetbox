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
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:code) }

  describe "#generate_code" do
    it "generates code on initialization" do
      code = invitation.code
      expect(code).to be_present
      expect(code).to match(/\w{16}/)

      invitation.save
      expect(invitation.reload.code).to eq(code)
    end
  end

  describe 'Invitation::ACTIVE_INVITATION_PERIOD' do
    it "an invitation should be active for 7 days" do
      expect(Invitation::ACTIVE_INVITATION_PERIOD).to eq(7.days)
    end
  end

  describe "#set_expires_at" do
    it "sets expiration timestamp on creation" do
      Timecop.freeze
      expect(invitation.expires_at).to be_blank
      invitation.save
      expect(invitation.expires_at).to be_present
      expect(invitation.expires_at).to eq(Invitation::ACTIVE_INVITATION_PERIOD.from_now)
      Timecop.return
    end
  end

  describe "#to_param" do
    it "returns the code" do
      expect(invitation.to_param).to eq(invitation.code)
    end
  end
end

describe Invitation, 'persisted' do
  subject(:invitation) { Fabricate(:invitation) }
  it { should be_valid }

  it { should validate_uniqueness_of(:code) }

  describe "#deactivate!" do
    it "deactivates the invitation" do
      expect(invitation).to_not be_expired
      invitation.deactivate!
      expect(invitation).to be_expired
    end
  end

  describe "#reactivate!" do
    it "reactivates the invitation for a certain period of time" do
      invitation.deactivate!
      expect(invitation).to be_expired

      Timecop.freeze
      invitation.reactivate!
      expect(invitation).to_not be_expired
      expect(invitation.expires_at).to eq(Invitation::ACTIVE_INVITATION_PERIOD.from_now)
      Timecop.return
    end
  end

  describe "#expired?" do
    it "returns false when invitation is not expired" do
      invitation.expires_at = 1.week.from_now
      expect(invitation).to_not be_expired
    end

    it "returns true when invitation is expired" do
      invitation.expires_at = 1.week.ago
      expect(invitation).to be_expired
    end
  end

  describe "#use!(invitee)" do
    let(:invitee) { Fabricate(:user) }

    it "records the invitee" do
      invitation.use!(invitee)
      expect(invitation.reload.invitee).to eq(invitee)
    end

    it "sets the used_at timestamp" do
      Timecop.freeze
      invitation.use!(invitee)
      expect(invitation.used_at).to eq(Time.current)
      expect(invitation).to be_used
      Timecop.return
    end
  end

  describe "used?" do
    it "returns true when used_at timestamp is set" do
      invitation.used_at = Time.current
      expect(invitation).to be_used
    end

    it "returns true when invitee is set" do
      invitation.invitee = Fabricate.build(:user)
      expect(invitation).to be_used
    end
  end

  describe "#active?" do
    it "returns true on a new record" do
      invitation = Fabricate.build(:invitation)
      expect(invitation).to be_active
    end

    it "returns true on persisted invitation" do
      expect(invitation).to be_active
    end

    it "returns false if used" do
      invitation.used_at = Time.current
      expect(invitation).to_not be_active
    end

    it "returns false if expired" do
      invitation.expires_at = Time.current
      expect(invitation).to_not be_active
    end
  end

  describe "#deliver_mail" do
    it "sends an invitation email" do
      mail = stub
      Mailer.expects(:invitation_instructions).with(invitation).returns(mail)
      mail.expects(:deliver)

      invitation.deliver_mail
    end
  end
end
