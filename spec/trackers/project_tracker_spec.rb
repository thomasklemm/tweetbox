require 'spec_helper'

describe ProjectTracker do
  let(:project) { Fabricate(:project) }
  let(:user)    { Fabricate(:user)  }
  subject(:tracker) { ProjectTracker.new(project, user) }

  describe "#track_create" do
    it "tracks the project creation" do
      VCR.use_cassette('trackers/project/track_create') do
        tracker.track_create
      end
    end
  end

  describe "#track_update" do
    it "tracks the project update" do
      VCR.use_cassette('trackers/project/track_update') do
        tracker.track_update
      end
    end
  end
end
