require 'spec_helper'

describe MentionsTimelineWorker do
  include_context 'signup and twitter account'

  describe "#perform" do
    context "active job" do
      it "fetches the mentions timeline for the given twitter account from Twitter" do
        VCR.use_cassette('mention_timelines/tweetbox101') do
          MentionsTimelineWorker.new.perform(twitter_account.id, Time.current)
          expect(project).to have(20).tweets
          expect(twitter_account.reload.max_mentions_timeline_twitter_id).to eq(350338584332603392)
        end
      end
    end

    context "expired job" do
      it "expires job 90 seconds after perform_at timestamp" do
        # Should instantly return and not perform any HTTP request
        MentionsTimelineWorker.new.perform(twitter_account.id, 90.seconds.ago)
        expect(project).to have(0).tweets
      end
    end
  end
end
