require 'spec_helper'

describe Invitation::Base do
  let(:invitation) { Fabricate.build(:invitation) }
  subject { Fabricate.build(:invitation_base, invitation: invitation) }
  it { should be_valid }

  it_should_behave_like FormObject

  it { should respond_to(:invitation) }
  it { should respond_to(:invitation=) }
  it { should validate_presence_of(:invitation) }

  it { should respond_to(:user) }
  it { should respond_to(:user=) }
  it { should validate_presence_of(:user) }

  it "returns the invitation's account" do
    expect(subject.account).to eq(invitation.account)
  end

  it "returns the invitation code" do
    expect(subject.code).to eq(invitation.code)
  end

  it "sets an invitation through assigning an invitation code", :pending do
    other_invitation = Fabricate(:invitation)
    subject.code = other_invitation.code
    expect(subject.invitation).to eq(other_invitation)
  end

  describe "#private_methods" do
    let(:invitation) { Fabricate(:invitation) }
    subject { Fabricate(:invitation_base, invitation: invitation) }

    describe "#persist!" do
      after { subject.send(:persist!) }

      it "creates account membership and project permissions" do
        subject.expects(:create_membership_and_permissions).returns(true)
      end

      it "marks invitation as used" do
        subject.expects(:use_invitation!).returns(true)
      end
    end

    describe "#create_membership_and_permissions" do
      context "with basic invitation" do
        before { subject.send(:create_membership_and_permissions) }

        it "creates basic account membership" do
          expect(subject.user).to be_member_of(invitation.account)
          expect(subject.user).to_not be_admin_of(invitation.account)
        end

        it "creates permissions for the projects specified in the invitation" do
          invitation.projects.all? { |project| expect(subject.user).to be_member_of(project) }
        end
      end

      context "with invitation to become admin" do
        let(:invitation) { Fabricate(:invitation, admin: true) }

        it "creates admin account membership" do
          subject.send(:create_membership_and_permissions)
          expect(subject.user).to be_member_of(invitation.account)
          expect(subject.user).to be_admin_of(invitation.account)
        end

        it "creates permissions for all projects on the account"
      end
    end

    describe "#use_invitation!" do
      it "marks invitation as used" do
        subject.send(:use_invitation!)
        expect(invitation.reload).to be_used
      end
    end
  end
end
