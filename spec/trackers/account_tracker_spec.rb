require 'spec_helper'

describe AccountTracker do
  let(:account) { Fabricate(:account) }
  let(:user)    { Fabricate(:user)  }
  subject(:tracker) { AccountTracker.new(account, user) }

  describe "#track_create" do
    it "tracks the account creation" do
      VCR.use_cassette('trackers/account/track_create') do
        tracker.track_create
      end
    end
  end
end
