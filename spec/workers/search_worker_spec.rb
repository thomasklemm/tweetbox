require 'spec_helper'

describe SearchWorker do
  include_context 'signup and twitter account'
  let(:search) { Fabricate(:search, query: 'Rainmakers :)', twitter_account: twitter_account) }

  describe "#perform" do
    context "active job" do
      it "fetches the search results from Twitter" do
        VCR.use_cassette('searches/rainmakers_positive') do
          SearchWorker.new.perform(search.id, Time.current)
          expect(project).to have(1).tweets
          expect(search.reload.max_twitter_id).to eq(357138819960676352)
        end
      end
    end

    context "expired job" do
      it "expires job 90 seconds after perform_at timestamp" do
        # Should instantly return and not perform any HTTP request
        SearchWorker.new.perform(search.id, 90.seconds.ago)
        expect(project).to have(0).tweets
      end
    end
  end
end
