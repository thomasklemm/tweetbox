require 'spec_helper'

describe UserTracker do
  let(:account) { Fabricate(:account) }
  let(:user)    { Fabricate(:user, account: account)  }
  subject(:tracker) { UserTracker.new(user) }

  describe "#track_create_by_signup" do
    it "tracks the user creation by signup" do
      VCR.use_cassette('trackers/user/track_create_by_signup') do
        tracker.track_create_by_signup
      end
    end
  end

  describe "#track_create_by_invitation" do
    it "tracks the user creation by invitation" do
      VCR.use_cassette('trackers/user/track_create_by_invitation') do
        tracker.track_create_by_invitation
      end
    end
  end
end
