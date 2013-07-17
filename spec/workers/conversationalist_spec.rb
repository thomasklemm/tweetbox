require 'spec_helper'

describe ConversationWorker do
  include_context 'signup and twitter account'
  it { should be_a Sidekiq::Worker }

  let(:tweet) { fetch_and_make_tweet(357166507249250304) }

  describe "#perform" do
    before do
      statuses_cassette('357166507249250304_previous_tweets') do
        ConversationWorker.new.perform(tweet.id)
      end
    end

    it "fetches the conversation for the given tweet" do
      expect(tweet).to have(1).previous_tweets

      expect(tweet.previous_tweet).to be_a Tweet
      expect(tweet.previous_tweet).to be_persisted
    end
  end
end
