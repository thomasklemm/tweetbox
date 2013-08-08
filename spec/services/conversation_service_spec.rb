describe ConversationService do
  include_context 'signup and twitter account'

  # Status ids
  # no_reply: 355002886155018242
  # single_reply: 357166507249250304
  # multiple_replies: 352253750477467648

  let(:reply_tweet)     { fetch_and_make_tweet(352253750477467648) }
  let(:no_reply_tweet)  { fetch_and_make_tweet(355002886155018242) }

  let(:reply_conversation)    { ConversationService.new(reply_tweet) }
  let(:no_reply_conversation) { ConversationService.new(no_reply_tweet) }

  describe "#previous_tweet" do
    context "tweet is a reply" do
      let!(:previous_tweet) do
        statuses_cassette("#{ reply_tweet.twitter_id }_previous_tweet") { reply_tweet.previous_tweet }
      end

      it "find the previous tweet in the database if present" do
        # Fetches tweet from the database
        # VCR would raise an error if an HTTP request would be performed
        expect(reply_tweet.previous_tweet).to eq(previous_tweet)
      end


      it "fetches the previous tweet from Twitter if it is not already persisted in the database" do
        expect(previous_tweet).to be_persisted
        expect(previous_tweet.current_state).to eq :conversation
        expect(previous_tweet.twitter_account).to be_nil
      end

      it "returns a tweet" do
        expect(previous_tweet).to be_a Tweet
      end
    end

    context "tweet is not a reply" do
      let(:previous_tweet) { no_reply_tweet.previous_tweet }

      it "returns nil" do
        expect(previous_tweet).to be_nil
      end
    end
  end

  describe "#previous_tweets" do
    context "tweet is a reply" do
      let!(:previous_tweets) do
        statuses_cassette("#{ reply_tweet.twitter_id }_previous_tweets") { reply_conversation.previous_tweets }
      end

      it "fetches and persists the previous tweets in the database and returns an array of previous tweets" do
        expect(previous_tweets.to_a).to be_an Array
        expect(previous_tweets.to_a.length).to eq 8

        expect(previous_tweets.first).to be_a Tweet
        expect(previous_tweets.first).to be_persisted
      end

      it "returns the previous tweets from the database when present" do
        # Does not trigger another HTTP request
        expect(reply_conversation.previous_tweets.to_a).to match_array(previous_tweets.to_a)

        # Associations
        reply_tweet.reload
        expect(reply_tweet).to have(8).previous_tweets
        expect(reply_tweet.previous_tweets.to_a).to match_array(previous_tweets.to_a)
      end
    end

    context "tweet is not a reply" do
      let(:previous_tweets) { no_reply_conversation.previous_tweets }

      it "returns an empty array" do
        expect(previous_tweets).to eq []
      end
    end
  end
end
