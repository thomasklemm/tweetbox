require 'spec_helper'

describe TweetPusher do
  let(:tweet) { Fabricate.build(:tweet) }
  subject(:tweet_pusher) { TweetPusher.new(tweet) }

  describe "#push_replace_tweet" do
    it "pushes a newly rendered tweet to the client using Pusher" do
      VCR.use_cassette('services/tweet_pusher') do
        tweet_pusher.push_replace_tweet
      end
    end
  end
end
