require 'spec_helper'

describe Lead do
  include_context 'signup and twitter account'

  describe ".from_twitter(Twitter::User.new)" do
    it "creates the given lead and assigns fields" do
      VCR.use_cassette('users/simyo') do
        # Lead
        user = twitter_account.client.user('simyo')
        lead = Lead.from_twitter(user)

        expect(lead.twitter_id).to eq(user.id)
        expect(lead.screen_name).to eq(user.screen_name)
        expect(lead.name).to eq(user.name)
        expect(lead.description).to eq("Der offizielle simyo Deutschland Twitter-Account. http://www.simyo.de/de/unternehmen/impressum.html") # expanded url
        expect(lead.location).to eq(user.location)
        expect(lead.profile_image_url).to eq(user.profile_image_url_https)
        expect(lead.url).to eq("http://www.simyo.de/") # expanded url
        expect(lead.followers_count).to eq(user.followers_count)
        expect(lead.statuses_count).to eq(user.statuses_count)
        expect(lead.friends_count).to eq(user.friends_count)
        expect(lead.joined_twitter_at).to eq(user.created_at)
        expect(lead.lang).to eq(user.lang)
        expect(lead.time_zone).to eq(user.time_zone)
        expect(lead.verified).to eq(user.verified)
        expect(lead.following).to eq(user.following)

        expect{ Lead.from_twitter(user) }.to_not raise_error

        # Free tweet
        status = user.status
        tweet = lead.tweets.first

        expect(tweet.twitter_id).to eq(status.id)

        expect{ LeadTweet.from_twitter(status) }.to_not raise_error
      end
    end
  end
end
