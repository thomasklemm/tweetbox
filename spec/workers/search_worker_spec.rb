require 'spec_helper'

describe SearchWorker do
  include_context 'signup and twitter account'

  describe "#perform" do
    let(:search) { Fabricate(:search, query: 'Rainmakers :)', twitter_account: twitter_account) }

    before do
      expect(Author.count).to eq 0
      expect(Tweet.count).to eq 0

      VCR.use_cassette('searches/rainmakers_in_positive_sentiment') do
        SearchWorker.new.perform(search.id)
      end
    end

    it "creates tweets and authors for the associated project" do
      expect(project.authors.count).to eq(4)
      expect(project.tweets.count).to eq(4)
    end

    it "sets max twitter id" do
      expect(search.reload.max_twitter_id).to eq(354815379941498880)
    end
  end
end
