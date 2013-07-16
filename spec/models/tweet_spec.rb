require 'spec_helper'

describe Tweet do
  subject(:tweet) { Fabricate.build(:tweet) }
  it { should be_valid }

  it { should belong_to(:project) }
  it { should belong_to(:author) }
  it { should belong_to(:twitter_account) }

  it { should validate_presence_of(:project) }
  it { should validate_presence_of(:author) }
  it { should validate_presence_of(:twitter_id) }
  it { should validate_presence_of(:state) }

  it { should have_many(:events).dependent(:destroy) }

  describe "named scopes" do
    it "describes :incoming, :resolved and :posted named scopes" do
      expect(Tweet).to respond_to :incoming
      expect(Tweet).to respond_to :resolved
      expect(Tweet).to respond_to :posted
    end
  end

  describe "state machine" do
    let(:conversation_tweet) { Fabricate.build(:tweet, state: :conversation) }
    let(:incoming_tweet) { Fabricate.build(:tweet, state: :incoming) }
    let(:resolved_tweet) { Fabricate.build(:tweet, state: :resolved) }
    let(:posted_tweet) { Fabricate.build(:tweet, state: :posted) }

    it "recognizes :conversation, :incoming, :resolved and :posted states" do
      expect(Tweet.available_states).to match_array([:conversation, :incoming, :resolved, :posted])
    end

    it "is initialized in :conversation state unless otherwise instructed" do
      expect(tweet.current_state).to eq :conversation
    end

    it "defines :activate and :resolve events" do
      expect(Tweet.available_events).to match_array([:activate, :resolve])
    end

    it "defines transitions betweet states on those events" do
      expect(conversation_tweet.available_transitions).to match_array([:activate])
      expect(incoming_tweet.available_transitions).to match_array([:activate, :resolve])
      expect(resolved_tweet.available_transitions).to match_array([:activate, :resolve])
      expect(posted_tweet.available_transitions).to match_array([])
    end
  end

  describe "#to_param" do
    it "returns the twitter_id" do
      expect(tweet.to_param).to eq tweet.twitter_id
    end
  end
end

describe Tweet, 'persisted' do
  subject(:tweet) { Fabricate(:tweet) }
  it { should be_valid }

  it { should validate_uniqueness_of(:twitter_id).scoped_to(:project_id) }
end
