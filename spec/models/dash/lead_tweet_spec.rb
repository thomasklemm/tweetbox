require 'spec_helper'

describe LeadTweet do
  include_context 'signup and twitter account'

  describe ".from_twitter(Twitter::Tweet.new)" do
    it "creates the given tweet and assigns fields" do
      VCR.use_cassette('statuses/351779153646858241') do
        # LeadTweet
        status = twitter_account.client.status('351779153646858241')
        tweet = LeadTweet.from_twitter(status)

        expect(tweet.twitter_id).to eq(status.id)
        expect(tweet.text).to_not eq(status.text) # has expanded urls
        expect(tweet.text).to eq(LeadTweet.new.expand_urls(status.text, status.urls))
        expect(tweet.in_reply_to_user_id).to eq(status.in_reply_to_user_id)
        expect(tweet.in_reply_to_status_id).to eq(status.in_reply_to_status_id)
        expect(tweet.source).to eq(status.source)
        expect(tweet.lang).to eq(status.lang)
        expect(tweet.retweet_count).to eq(status.retweet_count)
        expect(tweet.favorite_count).to eq(status.favorite_count)
        expect(tweet.created_at).to eq(status.created_at)

        expect{ LeadTweet.from_twitter(status) }.to_not raise_error

        # Lead
        user = status.user
        lead = tweet.lead

        expect(lead.twitter_id).to eq(user.id)
        expect(lead.screen_name).to eq(user.screen_name)

        expect{ Lead.from_twitter(user) }.to_not raise_error
      end
    end
  end
end
