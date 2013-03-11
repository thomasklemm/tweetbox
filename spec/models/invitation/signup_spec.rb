require 'spec_helper'

describe Invitation::Signup do
  let(:invitation) { Fabricate(:invitation) }
  subject { Fabricate(:invitation_signup, invitation: invitation) }
  it { should be_valid }

  it_should_behave_like FormObject

  it { should respond_to(:invitation) }
  it { should respond_to(:invitation=) }
  it { should validate_presence_of(:invitation) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }

  it { should respond_to(:user) }
  it { should respond_to(:membership) }

  it "returns the invitation code" do
    expect(subject.code).to eq(invitation.code)
  end

  it "can set an invitation through assigning an invitation code" do
    other_invitation = Fabricate(:invitation)
    subject.code = other_invitation.code
    expect(subject.invitation).to eq(other_invitation)
  end

  describe "#save" do
    context "with valid params" do
      before do
        @result = subject.save
      end

      it "returns true" do
        expect(@result).to be_true
      end

      it "creates the user in the database" do
        expect(subject.user).to be_persisted
      end

      it "creates an account membership" do
        expect(subject.membership).to be_persisted
        expect(subject.user).to be_member_of(invitation.account)
      end

      context "with invitation to become admin" do
        let(:invitation) { Fabricate(:invitation, admin: true) }
        it "makes the user an account admin" do
          expect(subject.user).to be_admin_of(invitation.account)
        end
      end

      context "with standard invitation" do
        it "makes the user an account admin" do
          expect(subject.user).to_not be_admin_of(invitation.account)
        end
      end

      it "sets the used flag on the invitation" do
        expect(invitation.reload).to be_used
      end
    end

    context "with invalid params" do
      let!(:another_user) { Fabricate(:user) }
      subject { Fabricate(:invitation_signup, email: another_user.email) }

      it "returns false" do
        expect(subject.save).to be_false
      end

      it "adds user validation errors to invitation signup" do
        subject.save
        expect(subject.errors[:email]).to eq(["has already been taken"])
      end

      it "doesn't create a membership" do
        expect { subject.save }.to_not change { Membership.count }
      end
    end
  end
end
