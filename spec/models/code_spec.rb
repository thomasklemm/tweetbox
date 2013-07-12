require 'spec_helper'

describe Code do
  subject(:code) { Fabricate.build(:code) }
  it { should be_valid }

  it { should belong_to(:tweet) }

  describe "#to_param" do
    it "returns the id" do
      expect(code.to_param).to eq(code.id)
    end
  end
end
