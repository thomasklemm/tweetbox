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
end

describe Tweet, 'persisted' do
  include_context 'signup and twitter account'

  # Status ids
  # no_reply: 355002886155018242
  # single_reply: 357166507249250304
  # multiple_replies: 352253750477467648

  subject(:tweet) { fetch_and_make_tweet(357166507249250304) }
  it { should be_valid }

  it { should validate_uniqueness_of(:twitter_id).scoped_to(:project_id) }

  ##
  # Reply and previous tweet

  describe "#reply?" do
    it "returns true if tweet is a reply" do
      tweet.in_reply_to_status_id = 123456789123
      expect(tweet).to be_reply

      tweet.in_reply_to_status_id = nil
      expect(tweet).to_not be_reply
    end
  end

  describe "#previous_tweet_id" do
    it "returns in_reply_to_status_id" do
      tweet.in_reply_to_status_id = 123456789123
      expect(tweet.previous_tweet_id).to eq(tweet.in_reply_to_status_id)
    end
  end

  describe "#previous_tweet" do
    context "if tweet is a reply" do
      it "fetches and returns the previous tweet" do
        statuses_cassette("#{ tweet.twitter_id }_previous_tweet") do
          expect(tweet.previous_tweet).to be_a Tweet
          expect(tweet.previous_tweet).to be_persisted
        end
      end
    end

    it "returns nil unless tweet is a reply" do
      tweet.in_reply_to_status_id = nil
      expect(tweet.previous_tweet).to be_nil
    end
  end

  describe "#previous_tweets" do
    context "if tweet is a reply" do
      before do
        statuses_cassette("#{ tweet.twitter_id }_previous_tweet") do
          @previous_tweets = tweet.previous_tweets
        end
      end

      it "fetches and returns the previous tweets from Twitter" do
        expect(@previous_tweets).to be_an Array
        expect(@previous_tweets.first).to be_a Tweet
      end

      it "returns the cached previous tweets from previous_tweets_ids" do
        # Memoized or cached results
        tweet.previous_tweets
      end
    end

    it "returns nil unless tweet is a reply?" do
      tweet.in_reply_to_status_id = nil
      expect(tweet.previous_tweets).to be_nil
    end
  end

  describe "#to_param" do
    it "returns the twitter_id" do
      expect(tweet.to_param).to eq tweet.twitter_id
    end
  end
end

describe Tweet, 'state machine' do
  subject(:tweet) { Fabricate.build(:tweet) }
  it { should be_valid }

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
