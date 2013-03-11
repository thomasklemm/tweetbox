require 'spec_helper'

describe Invitation::Registration do
  subject { Fabricate.build(:invitation_signup) }
  it { should have(1).error_on(:user) } # user can't be blank

  it { should be_kind_of(Invitation::Base) }

  describe "#save" do
    context "with valid invitation and user params" do
      let(:signup) { Fabricate(:invitation_signup) }

      it "saves the user in the database" do
        signup.save
        expect(signup.user).to be_persisted
      end

      it "calls persist!" do
        signup.expects(:persist!).returns(true).once
        signup.save
      end

      it "returns true" do
        expect(signup.save).to be_true
      end
    end

    context "with valid invitation and invalid user params" do
      let(:signup) { Fabricate(:invitation_signup, email: Fabricate(:user).email) }

      it "has 1 error on :email" do
        signup.save
        expect(signup.errors[:email]).to eq(["has already been taken"])
      end

      it "returns false" do
        expect(signup.save).to be_false
      end
    end

    context "without invitation" do
      subject { Fabricate(:invitation_signup, invitation: nil) }

      it { should have(1).error_on(:invitation) }

      it "returns false" do
        expect(subject.save).to be_false
      end
    end
  end
end
