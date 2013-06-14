# == Schema Information
#
# Table name: tweets
#
#  author_id             :integer          not null
#  created_at            :datetime         not null
#  id                    :integer          not null, primary key
#  in_reply_to_status_id :integer
#  in_reply_to_user_id   :integer
#  previous_tweet_ids    :integer
#  project_id            :integer          not null
#  state                 :text
#  text                  :text
#  twitter_account_id    :integer          not null
#  twitter_id            :integer          not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_tweets_on_previous_tweet_ids         (previous_tweet_ids)
#  index_tweets_on_project_id                 (project_id)
#  index_tweets_on_project_id_and_author_id   (project_id,author_id)
#  index_tweets_on_project_id_and_state       (project_id,state)
#  index_tweets_on_project_id_and_twitter_id  (project_id,twitter_id) UNIQUE
#

require 'spec_helper'

describe Tweet do
  subject(:tweet) { Fabricate.build(:tweet) }
  it { should be_valid }

  it { should belong_to(:project) }
  it { should validate_presence_of(:project) }

  it { should validate_uniqueness_of(:twitter_id).scoped_to(:project_id) }

  it { should belong_to(:author) }
  it { should validate_presence_of(:author) }

  describe "workflow" do
    it "has :new, :open, :closed, and :conversation states" do
      expect(Tweet.workflow_spec.state_names).to eq([:new, :open, :closed, :conversation])
    end

    context "in :new state" do
      let(:tweet) { Fabricate.build(:tweet, workflow_state: :new) }

      it "defines only :open! and :close! events" do
        events = tweet.current_state.events.keys
        expect(events).to eq([:open, :close])
      end

      it "has :open! event that transitions to :open state" do
        transition = tweet.current_state.events[:open].transitions_to
        expect(transition).to eq(:open)
      end

      it "has :close! event that transitions to :closed state" do
        transition = tweet.current_state.events[:close].transitions_to
        expect(transition).to eq(:closed)
      end
    end

    context "in :open state" do
      let(:tweet) { Fabricate.build(:tweet, workflow_state: :open) }

      it "defines only :open! and :close! events" do
        events = tweet.current_state.events.keys
        expect(events).to eq([:open, :close])
      end

      it "has :open! event that transitions to :open state" do
        transition = tweet.current_state.events[:open].transitions_to
        expect(transition).to eq(:open)
      end

      it "has :close! event that transitions to :closed state" do
        transition = tweet.current_state.events[:close].transitions_to
        expect(transition).to eq(:closed)
      end
    end

    context "in :closed state" do
      let(:tweet) { Fabricate.build(:tweet, workflow_state: :closed) }

      it "defines only :open! and :close! events" do
        events = tweet.current_state.events.keys
        expect(events).to eq([:open, :close])
      end

      it "has :open! event that transitions to :open state" do
        transition = tweet.current_state.events[:open].transitions_to
        expect(transition).to eq(:open)
      end

      it "has :close! event that transitions to :closed state" do
        transition = tweet.current_state.events[:close].transitions_to
        expect(transition).to eq(:closed)
      end
    end

    context "in :conversation state" do
      let(:tweet) { Fabricate.build(:tweet, workflow_state: :conversation) }

      it "doesn't define any events" do
        events = tweet.current_state.events.keys
        expect(events).to be_empty
      end
    end
  end

  let(:project)  { Fabricate(:project) }
  let(:status)   { Fabricate.build(:twitter_status) }
  let(:statuses) { [Fabricate.build(:twitter_status), Fabricate.build(:twitter_status)] }

  describe ".from_twitter(statuses, options={})" do
    it "requires a project" do
      expect { Tweet.from_twitter([], source: :mentions) }.to raise_error(KeyError)
    end

    it "requires a source" do
      expect { Tweet.from_twitter([], project: project) }.to raise_error(KeyError)
    end

    context "with one status and valid params" do
      subject(:tweets) { Tweet.from_twitter(statuses, project: project, source: :mentions) }

      it "returns an array of tweets" do
        expect(tweets).to be_an(Array)
        expect(tweets.first).to be_a(Tweet)
      end

      it "reverses the statuses before processing" do
        expect(tweets.first.twitter_id).to eq(statuses.last.id)
      end
    end
  end

  describe ".create_tweet_from_twitter(project, status, source)" do
    subject(:tweet) { Tweet.create_tweet_from_twitter(project, status, source) }

    it "returns the tweet" do
      expect(tweet).to be_a(Tweet)
    end
  end

  let(:author) { Author.find_or_create_author(project, status) }
  let(:source) { :mentions }

  describe ".find_or_create_tweet(project, status, author, source)" do
    subject(:tweet) { Tweet.find_or_create_tweet(project, status, author, source) }

    it "returns the tweet" do
      expect(tweet).to be_a(Tweet)
      expect(tweet).to be_persisted
      expect(tweet.twitter_id).to eq(status.id)
      expect(tweet.text).to eq(status.text)
      expect(tweet.author).to eq(author)
      expect(tweet.project).to eq(project)
      expect(tweet.current_state).to eq(:new) # REVIEW: SPECIFY CONVERSATION STATE
    end
  end

  describe "#assign_fields_from_status(status)" do
    let(:status) { Fabricate.build(:twitter_status) }
    before { tweet.assign_fields_from_status(status) }

    it "assigns the tweet's fields" do
      expect(tweet.twitter_id).to eq(status.id)
      expect(tweet.text).to eq(status.text)
      expect(tweet.created_at).to eq(status.created_at)
      expect(tweet.in_reply_to_status_id).to eq(status.in_reply_to_status_id)
      expect(tweet.in_reply_to_user_id).to eq(status.in_reply_to_user_id)
    end
  end

  describe "#assign_workflow_state(source)" do
    it "assigns :conversation state if source is :building_conversations" do
      tweet.assign_workflow_state(:building_conversations)
      expect(tweet.current_state).to eq(:conversation)
    end

    it "doesn't assign :conversation state unless source is :building_conversations" do
      tweet.assign_workflow_state(:mentions_timeline)
      expect(tweet.current_state).to_not eq(:conversation)
    end
  end
end
