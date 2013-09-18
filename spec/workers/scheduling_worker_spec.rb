require 'spec_helper'

describe SchedulingWorker do
  include_context 'signup and twitter account'

  before { twitter_account }

  after do
    MentionsTimelineWorker.jobs.clear
    UserTimelineWorker.jobs.clear
    SearchWorker.jobs.clear
  end

  describe "#perform" do
    it "performs mentions timeline queries async" do
      expect(MentionsTimelineWorker).to have(0).jobs
      SchedulingWorker.new.perform
      expect(MentionsTimelineWorker).to have(1).jobs
    end

    it "performs user timeline queries async" do
      expect(UserTimelineWorker).to have(0).jobs
      SchedulingWorker.new.perform
      expect(UserTimelineWorker).to have(1).jobs
    end

    it "performs search queries async" do
      Fabricate(:search)

      expect(SearchWorker).to have(0).jobs
      SchedulingWorker.new.perform
      expect(SearchWorker).to have(1).jobs
    end
  end
end
