require 'spec_helper'

describe Activity do
  subject(:activity) { Fabricate(:activity) }
  it { should be_valid }

  it { should belong_to(:tweet) }
  it { should belong_to(:user) }
  it { should belong_to(:project) }

  it { should validate_presence_of(:tweet) }
  it { should validate_presence_of(:user) }

  describe "callbacks" do
    before { activity.save }

    it "assigns the project from the tweet" do
      expect(activity.project).to be_present
      expect(activity.project).to eq(activity.tweet.project)
    end
  end

  describe "project=" do
    it "raises NotImplementedError" do
      expect{ activity.project = nil }.to raise_error(NotImplementedError)
    end
  end

  # Kind
  it { should validate_presence_of(:kind) }
  it { should ensure_inclusion_of(:kind).in_array(Activity::VALID_KINDS) }

  describe 'Activity::VALID_KINDS' do
    it "describes certain valid kinds of activitys" do
      expect(Activity::VALID_KINDS).to match_array(%w(resolve start_reply post_reply post retweet favorite unfavorite))
    end
  end

  describe "kind=" do
    before { activity.kind = nil }

    Activity::VALID_KINDS.each do |kind|
      it "accepts '#{ kind.to_s }' string" do
        activity.kind = kind.to_s

        expect(activity).to be_valid
        expect(activity.kind).to eq(kind)
      end

      it "accepts :#{ kind.to_sym } symbol" do
        activity.kind = kind.to_sym

        expect(activity).to be_valid
        expect(activity.kind).to eq(kind)
      end
    end
  end
end
