require 'spec_helper'

describe Author do
  subject(:author) { Fabricate.build(:author) }
  it { should be_valid }

  it { should belong_to(:project) }
  it { should have_many(:tweets) }

  it { should validate_presence_of(:project) }
  it { should validate_presence_of(:twitter_id) }
  it { should validate_presence_of(:screen_name) }

  describe "#at_screen_name" do
    it "returns '@screen_name'" do
      author.screen_name = 'thomasjklemm'
      expect(author.at_screen_name).to eq '@thomasjklemm'
    end
  end
end

describe Author, 'persisted' do
  subject(:author) { Fabricate(:author) }
  it { should be_valid }

  it { should validate_uniqueness_of(:twitter_id).scoped_to(:project_id) }
end
