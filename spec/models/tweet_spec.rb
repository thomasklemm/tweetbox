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

  describe "#twitter_account" do
    let(:twitter_account) { Fabricate.build(:twitter_account) }

    it "returns the twitter account that has been used to fetch the tweet when present" do
      tweet.twitter_account = twitter_account
      expect(tweet.twitter_account).to eq twitter_account
    end

    it "returns the project's default twitter account as a fallback" do
      tweet.twitter_account = nil
      tweet.project.default_twitter_account = twitter_account
      expect(tweet.twitter_account).to eq twitter_account
    end
  end
end

describe Tweet, 'class methods' do
  include_context 'signup and twitter account'

  describe ".many_from_twitter" do
    it "requires a :project" do
      expect{ Tweet.many_from_twitter([Object.new]) }.to raise_error(RuntimeError, 'Requires a :project')
    end

    it "requires a :state" do
      expect{ Tweet.many_from_twitter([Object.new], project: Object.new) }.to raise_error(RuntimeError, 'Requires a :state')
    end

    it "creates the given tweets and returns an array of tweet records" do
      VCR.use_cassette('user_timelines/simyo') do
        statuses = twitter_account.client.user_timeline('simyo', count: 5)
        tweets = Tweet.many_from_twitter(statuses, project: project, twitter_account: twitter_account, state: :incoming)

        status = statuses.first
        tweet = tweets.first

        # Return value
        expect(tweets).to be_an Array

        expect(tweet).to be_a Tweet
        expect(tweet).to be_persisted

        # Associations
        expect(tweet.project).to eq project
        expect(tweet.twitter_account).to eq twitter_account
        expect(tweet.state).to eq :incoming

        # Fields
        expect(tweet.twitter_id).to eq(status.id)
        expect(tweet.text).to_not eq(status.text) # has expanded urls
        expect(tweet.text).to eq(Tweet.new.expand_urls(status.text, status.urls))
        expect(tweet.in_reply_to_user_id).to eq(status.in_reply_to_user_id)
        expect(tweet.in_reply_to_status_id).to eq(status.in_reply_to_status_id)
        expect(tweet.source).to eq(status.source)
        expect(tweet.lang).to eq(status.lang)
        expect(tweet.retweet_count).to eq(status.retweet_count)
        expect(tweet.favorite_count).to eq(status.favorite_count)
        expect(tweet.created_at).to eq(status.created_at)

        expect{ Tweet.many_from_twitter(statuses, project: project, state: :incoming) }.to_not raise_error
      end
    end
  end

  describe ".from_twitter" do
    it "requires a :project" do
      expect{ Tweet.from_twitter(Object.new) }.to raise_error(RuntimeError, 'Requires a :project')
    end

    it "requires a :state" do
      expect{ Tweet.from_twitter(Object.new, project: Object.new) }.to raise_error(RuntimeError, 'Requires a :state')
    end

    it "creates the given tweet and returns a tweet record" do
      VCR.use_cassette('statuses/351779153646858241') do
        status = twitter_account.client.status('351779153646858241')
        tweet = Tweet.from_twitter(status, project: project, twitter_account: twitter_account, state: :incoming)

        # Return value
        expect(tweet).to be_a Tweet
        expect(tweet).to be_persisted

        # Associations
        expect(tweet.project).to eq project
        expect(tweet.twitter_account).to eq twitter_account
        expect(tweet.state).to eq :incoming

        # Fields
        expect(tweet.twitter_id).to eq(status.id)
        expect(tweet.text).to_not eq(status.text) # has expanded urls
        expect(tweet.text).to eq(Tweet.new.expand_urls(status.text, status.urls))
        expect(tweet.in_reply_to_user_id).to eq(status.in_reply_to_user_id)
        expect(tweet.in_reply_to_status_id).to eq(status.in_reply_to_status_id)
        expect(tweet.source).to eq(status.source)
        expect(tweet.lang).to eq(status.lang)
        expect(tweet.retweet_count).to eq(status.retweet_count)
        expect(tweet.favorite_count).to eq(status.favorite_count)
        expect(tweet.created_at).to eq(status.created_at)

        expect{ Tweet.from_twitter(status, project: project, state: :incoming) }.to_not raise_error

        # Author
        user = status.user
        author = tweet.author

        expect(author).to be_an Author
        expect(author).to be_persisted

        expect(author.twitter_id).to eq(user.id)
        expect(author.screen_name).to eq(user.screen_name)

        expect{ Author.from_twitter(user, project: project) }.to_not raise_error
      end
    end
  end
end
