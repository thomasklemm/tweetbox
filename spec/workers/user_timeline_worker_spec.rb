require 'spec_helper'

describe UserTimelineWorker do
  include_context 'signup and twitter account'
  include_examples 'sidekiq options'

  describe "#perform" do
    context "active job" do
      it "fetches the user timeline for the given twitter account from Twitter" do
        VCR.use_cassette('user_timelines/tweetbox101') do
          UserTimelineWorker.new.perform(twitter_account.id, Time.current)
          expect(project).to have(55).tweets
          expect(twitter_account.reload.max_user_timeline_twitter_id).to eq(355058461005987840)
        end
      end
    end

    context "expired job" do
      it "expires job 60 seconds after perform_at timestamp" do
        # Should instantly return and not perform any HTTP request
        UserTimelineWorker.new.perform(twitter_account.id, 60.seconds.ago)
        expect(project).to have(0).tweets
      end
    end
  end
end
