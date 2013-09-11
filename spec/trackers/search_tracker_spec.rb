require 'spec_helper'

describe SearchTracker do
  include_context 'signup and twitter account'
  let(:search) { Fabricate(:search, twitter_account: twitter_account) }
  subject(:tracker) { SearchTracker.new(search, user) }

  describe "#track_create" do
    it "tracks the search creation" do
      VCR.use_cassette('trackers/search/track_create') do
        tracker.track_create
      end
    end
  end

  describe "#track_update" do
    it "tracks the search update" do
      VCR.use_cassette('trackers/search/track_update') do
        tracker.track_update
      end
    end
  end

  describe "#track_destroy" do
    it "tracks the search destruction" do
      VCR.use_cassette('trackers/search/track_destroy') do
        tracker.track_destroy
      end
    end
  end
end
