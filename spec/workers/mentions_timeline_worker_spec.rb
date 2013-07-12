require 'spec_helper'

describe MentionsTimelineWorker do
  include_context 'signup and twitter account'

  describe "#perform" do
    before do
      expect(Author.count).to eq 0
      expect(Tweet.count).to eq 0

      VCR.use_cassette('mention_timelines/tweetbox101') do
        MentionsTimelineWorker.new.perform(twitter_account.id)
      end
    end

    it "creates tweets and authors for the associated project" do
      expect(project.authors.count).to eq(2)
      expect(project.tweets.count).to eq(20)
    end

    it "sets max twitter id for mentions timeline" do
      max_id = twitter_account.reload.max_mentions_timeline_twitter_id
      expect(max_id).to eq(350338584332603392)
    end
  end
end
