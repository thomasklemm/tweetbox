require 'spec_helper'

describe UserTimelineWorker do
  include_context 'signup and twitter account'

  describe "#perform" do
    before do
      expect(Author.count).to eq 0
      expect(Tweet.count).to eq 0

      VCR.use_cassette('user_timelines/tweetbox101') do
        UserTimelineWorker.new.perform(twitter_account.id)
      end
    end

    it "creates tweets and authors for the associated project" do
      expect(project.authors.count).to eq(1)
      expect(project.tweets.count).to eq(55)
    end

    it "sets max twitter id for user timeline" do
      max_id = twitter_account.reload.max_user_timeline_twitter_id
      expect(max_id).to eq(355058461005987840)
    end
  end
end
