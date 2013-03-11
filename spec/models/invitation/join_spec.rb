require 'spec_helper'

describe Invitation::Join do
  subject { Fabricate(:invitation_join) }
  it { should be_valid }

  it { should be_kind_of(Invitation::Base) }

  describe "#save" do
    context "with valid invitation and user" do
      it "returns true" do
        expect(subject.save).to be_true
      end

      it "calls #persist!" do
        subject.expects(:persist!).returns(true).once
        subject.save
      end
    end

    context "with missing invitation" do
      subject { Fabricate(:invitation_join, invitation: nil) }

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
