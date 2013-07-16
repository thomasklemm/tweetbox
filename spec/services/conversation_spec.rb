describe Conversation do
  include_context 'signup and twitter account'

  describe "#previous_tweet" do
    context "tweet is a reply" do
      it "find the previous tweet in the database if present"
      it "fetches the previous tweet from Twitter if it is not already persisted in the database"
      it "returns a tweet"
    end

    context "tweet is not a reply" do
      it "returns nil"
    end
  end

  describe "#previous_tweets" do
    context "tweet is a reply" do
      it "fetches the previous tweets from Twitter"
      it "persists all previous tweets in the database"
      it "returns an array of all previous tweets"
    end

    context "tweet is not a reply" do
      it "returns nil"
    end
  end

  describe "#fetch_and_cache_conversation" do
    it "fetches the conversation from Twitter"
    it "persists all tweets in the database"
    it "saves an array of previous tweet ids for instant conversations"
    it "returns true"
  end
end

# let(:status) do
#   VCR.use_cassette('statuses/355672648916799488') do
#     twitter_account.client.status('355672648916799488')
#   end
# end

# subject(:tweet) do
#   TweetMaker.from_twitter(status, project: project, twitter_account: twitter_account, state: :incoming)
# end

# describe "#fetch_and_cache_conversation" do
#   it "fetches the previous tweets" do
#     VCR.use_cassette('conversations/355672648916799488') do
#       tweet.fetch_previous_tweets_and_cache_ids

#       # Saves the previous tweet ids
#       expect(tweet.reload.previous_tweet_ids).to eq(
#         [355670264572411904, 355670656924389376, 355670723307646976,
#          355671255564824577, 355671803944898560, 355671909280653315]
#       )

#       # Does not trigger a second fetch
#       previous_tweet = tweet.previous_tweet

#       # No twitter account assigned
#       expect(previous_tweet.twitter_account).to be_blank

#       # Conversation state is assigned
#       expect(previous_tweet.current_state).to eq :conversation
#     end
#   end
# end
