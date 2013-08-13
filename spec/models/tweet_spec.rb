require 'spec_helper'

describe Tweet do
  subject(:tweet) { Fabricate.build(:tweet) }
  it { should be_valid }

  it { should validate_presence_of(:project) }
  it { should validate_presence_of(:author) }
  it { should validate_presence_of(:twitter_id) }
  it { should validate_presence_of(:state) }

  it { should belong_to(:project) }
  it { should belong_to(:author) }
  it { should belong_to(:twitter_account) }

  it { should have_many(:events).dependent(:destroy) }

  it { should have_many(:previous_conversations).dependent(:destroy).class_name(Conversation) }
  it { should have_many(:previous_tweets).through(:previous_conversations) }

  it { should have_many(:future_conversations).dependent(:destroy).class_name(Conversation) }
  it { should have_many(:future_tweets).through(:future_conversations) }
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

describe Tweet, 'conversation' do
  let!(:first_tweet)  { Fabricate(:tweet) }
  let!(:second_tweet) { Fabricate(:tweet) }
  let!(:third_tweet)  { Fabricate(:tweet) }

  describe "#previous_tweets" do
    it "sets and lists all previous tweets and updates counter caches" do
      third_tweet.previous_tweets << first_tweet
      expect(third_tweet.previous_tweets).to eq [first_tweet]
      expect(third_tweet.reload.previous_tweets_count).to eq 1

      # Use tweet.previous_tweets |= [future_tweet]
      third_tweet.previous_tweets |= [first_tweet]
      expect(third_tweet.previous_tweets).to eq [first_tweet]
      expect(third_tweet.reload.previous_tweets_count).to eq 1

      # Other side
      expect(first_tweet.future_tweets).to eq [third_tweet]
      expect(first_tweet.reload.future_tweets_count).to eq 1

      # Check for side effects
      expect(third_tweet.future_tweets).to eq []
      expect(third_tweet.reload.future_tweets_count).to eq 0

      # Check for side effects
      expect(first_tweet.previous_tweets).to eq []
      expect(first_tweet.reload.previous_tweets_count).to eq 0

      # More previous tweets
      third_tweet.previous_tweets |= [second_tweet]
      expect(third_tweet.previous_tweets).to eq [first_tweet, second_tweet]
      expect(third_tweet.reload.previous_tweets_count).to eq 2

      # Destroy join records
      # Use tweet.previous_tweets.delete(another_tweet)
      # Choose delete over destroy in this case as destroy right now messes with the counter cache
      third_tweet.previous_tweets.delete second_tweet
      expect(third_tweet.reload.previous_tweets_count).to eq 1
      expect(second_tweet.reload.future_tweets_count).to eq 0

      # Uniqueness index on both columns
      expect{ third_tweet.previous_tweets << first_tweet }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe "#future_tweets" do
    it "sets and lists all previous tweets and updates counter caches" do
      third_tweet.future_tweets << first_tweet
      expect(third_tweet.future_tweets).to eq [first_tweet]
      expect(third_tweet.reload.future_tweets_count).to eq 1

      third_tweet.future_tweets |= [first_tweet]
      expect(third_tweet.future_tweets).to eq [first_tweet]
      expect(third_tweet.reload.future_tweets_count).to eq 1

      # Other side
      expect(first_tweet.previous_tweets).to eq [third_tweet]
      expect(first_tweet.reload.previous_tweets_count).to eq 1

      # Check for side effects
      expect(third_tweet.previous_tweets).to eq []
      expect(third_tweet.reload.previous_tweets_count).to eq 0

      # Check for side effects
      expect(first_tweet.future_tweets).to eq []
      expect(first_tweet.reload.future_tweets_count).to eq 0

      # More previous tweets
      third_tweet.future_tweets |= [second_tweet]
      expect(third_tweet.future_tweets).to eq [first_tweet, second_tweet]
      expect(third_tweet.reload.future_tweets_count).to eq 2

      # Uniqueness index on both columns
      expect{ third_tweet.future_tweets << first_tweet }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end

describe Tweet, 'counter caches' do
  let!(:project) { Fabricate(:project) }
  let!(:incoming_tweets) { (1..3).map { Fabricate(:tweet, project: project, state: 'incoming') }}
  let!(:resolved_tweets) { (1..2).map { Fabricate(:tweet, project: project, state: :resolved) }}
  let!(:posted_tweets)   { (1..1).map { Fabricate(:tweet, project: project, state: :posted) }}

  before { project.reload }

  it "caches the tweet counts on the project" do
    expect(project.tweets_count).to eq 6
    expect(project.incoming_tweets_count).to eq 3
    expect(project.resolved_tweets_count).to eq 2
    expect(project.posted_tweets_count).to eq 1

    incoming_tweets.first.update(state: 'resolved')
    posted_tweets.first.update(state: :resolved)
    project.reload

    expect(project.tweets_count).to eq 6
    expect(project.incoming_tweets_count).to eq 2
    expect(project.resolved_tweets_count).to eq 4
    expect(project.posted_tweets_count).to eq 0

    resolved_tweets.first.destroy
    project.reload

    expect(project.tweets_count).to eq 5
    expect(project.incoming_tweets_count).to eq 2
    expect(project.resolved_tweets_count).to eq 3
    expect(project.posted_tweets_count).to eq 0

    project.update(tweets_count: 10, incoming_tweets_count: 10, resolved_tweets_count: 10, posted_tweets_count: 10)
    project.reload

    expect(project.tweets_count).to eq 10
    expect(project.incoming_tweets_count).to eq 10
    expect(project.resolved_tweets_count).to eq 10
    expect(project.posted_tweets_count).to eq 10

    Tweet.counter_culture_fix_counts
    project.reload

    expect(project.tweets_count).to eq 5
    expect(project.incoming_tweets_count).to eq 2
    expect(project.resolved_tweets_count).to eq 3
    expect(project.posted_tweets_count).to eq 0
  end
end
