require 'spec_helper'

describe Invitation::Join do
  subject { Fabricate.build(:invitation_join) }
  it { should be_valid }

  it_should_behave_like FormObject

  it { should respond_to(:invitation) }
  it { should respond_to(:invitation=) }
  it { should validate_presence_of(:invitation) }

  it { should respond_to(:user) }
  it { should respond_to(:user=) }
  it { should validate_presence_of(:user) }

  it { should respond_to(:membership) }
  it { should respond_to(:account) }

  describe "#save" do

    context "with valid invitation and user" do
      let(:invitation) { Fabricate(:invitation) }
      let(:user) { Fabricate(:user) }
      let(:join) { Fabricate.build(:invitation_join, invitation: invitation, user: user) }

      before { @result = join.save }

      it "returns true" do
        expect(@result).to be_true
      end

      describe "creates the account membership" do
        context "with admin invitation" do
          let(:invitation) { Fabricate(:invitation, admin: true) }

          it "creates membership" do
            expect(user).to be_member_of(invitation.account)
          end

          it "makes the user an admin" do
            expect(user).to be_admin_of(invitation.account)
          end
        end

        context "with standard non-admin invitation" do
          it "creates membership" do
            expect(user).to be_member_of(invitation.account)
          end

          it "doesn't make the user an admin" do
            expect(user).to_not be_admin_of(invitation.account)
          end
        end
      end
    end

    context "with missing invitation" do
      subject { Fabricate.build(:invitation_join, invitation: nil) }

      it "returns false" do
        expect(subject.save).to be_false
      end
    end

    context "with missing user" do
      subject { Fabricate.build(:invitation_join, user: nil) }

      it "returns false" do
        expect(subject.save).to be_false
      end
    end

  end
end
