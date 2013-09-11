require 'spec_helper'

describe TwitterAccountTracker do
  include_context 'signup and twitter account'
  subject(:tracker) { TwitterAccountTracker.new(twitter_account, user) }

  describe "#track_create" do
    it "tracks the twitter_account creation" do
      VCR.use_cassette('trackers/twitter_account/track_create') do
        tracker.track_create
      end
    end
  end

  describe "#track_update" do
    it "tracks the twitter_account update" do
      VCR.use_cassette('trackers/twitter_account/track_update') do
        tracker.track_update
      end
    end
  end

  describe "#track_destroy" do
    it "tracks the twitter_account destruction" do
      VCR.use_cassette('trackers/twitter_account/track_destroy') do
        tracker.track_destroy
      end
    end
  end
end
