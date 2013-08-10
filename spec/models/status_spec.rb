require 'spec_helper'

describe Status do
  subject(:status) { Fabricate.build(:status) }
  it { should be_valid }

  it { should belong_to(:project) }
  it { should belong_to(:user) }
  it { should belong_to(:twitter_account) }

  describe "#to_param" do
    it "returns the token" do
      expect(status.to_param).to eq(status.token)
    end
  end

  describe "#reply?" do
    context "in_reply_to_status_id is present" do
      it "returns true" do
        status.in_reply_to_status_id = 123456789
        expect(status).to be_reply
      end
    end

    context "in_reply_to_status_id is blank" do
      it "returns false" do
        status.in_reply_to_status_id = nil
        expect(status).to_not be_reply
      end
    end
  end
end

describe Status do
  include_context 'signup and twitter account'
  before { twitter_account }

  subject(:status) { Fabricate.build(:status, project: project, user: user) }

  describe "#previous_tweet" do
    context "status is a reply" do
      context "previous tweet is present in the database" do
        before { fetch_and_make_tweet(357166507249250304) }

        it "returns the tweet from the database without fetching it from Twitter" do
          status.in_reply_to_status_id = 357166507249250304
          previous_tweet = status.previous_tweet
          expect(previous_tweet).to be_persisted
          expect(previous_tweet.twitter_id).to eq(357166507249250304)
        end
      end

      context "previous tweet is not yet present in the database" do
        it "fetches the previous tweet from Twitter and returns it" do
          VCR.use_cassette('statuses/357166507249250304') do
            status.in_reply_to_status_id = 357166507249250304
            previous_tweet = status.previous_tweet
            expect(previous_tweet).to be_persisted
            expect(previous_tweet.twitter_id).to eq(357166507249250304)
          end
        end
      end
    end

    context "status is no reply" do
      it "returns nil" do
        expect(status.previous_tweet).to be_nil
      end
    end
  end
end
