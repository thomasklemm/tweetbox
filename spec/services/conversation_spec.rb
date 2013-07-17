describe Conversation do
  include_context 'signup and twitter account'

  # Status ids
  # no_reply: 355002886155018242
  # single_reply: 357166507249250304
  # multiple_replies: 352253750477467648

  let(:reply_tweet)     { fetch_and_make_tweet(352253750477467648) }
  let(:no_reply_tweet)  { fetch_and_make_tweet(355002886155018242) }

  let(:reply)    { Conversation.new(reply_tweet) }
  let(:no_reply) { Conversation.new(no_reply_tweet) }

  describe "#previous_tweet" do
    context "tweet is a reply" do
      let(:previous_tweet) do
        statuses_cassette("#{ reply_tweet.twitter_id }_previous_tweet") { reply.previous_tweet }
      end

      it "find the previous tweet in the database if present" do
        previous_tweet

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
      let(:previous_tweet) { no_reply.previous_tweet }

      it "returns nil" do
        expect(previous_tweet).to be_nil
      end
    end
  end

  describe "#previous_tweets" do
    context "tweet is a reply" do
      let(:previous_tweets) do
        statuses_cassette("#{ reply_tweet.twitter_id }_previous_tweets") { reply.previous_tweets }
      end

      it "fetches the previous tweets from Twitter" do
        # Fetch tweets from Twitter
        previous_tweets

        # Does not trigger another HTTP request
        expect(reply.previous_tweets).to eq(previous_tweets)
      end

      it "persists all previous tweets in the database" do
        expect(previous_tweets.first).to be_a Tweet
        expect(previous_tweets.first).to be_persisted
      end

      it "returns an array of all previous tweets" do
        expect(previous_tweets).to be_an Array
        expect(previous_tweets.first).to be_a Tweet
      end
    end

    context "tweet is not a reply" do
      let(:previous_tweets) { no_reply.previous_tweets }

      it "returns nil" do
        expect(previous_tweets).to be_nil
      end
    end
  end

  describe "#fetch_and_cache_conversation" do
    before do
      @conversation = statuses_cassette("#{ reply_tweet.twitter_id }_previous_tweets") { reply.fetch_and_cache_conversation }
    end

    it "fetches the conversation from Twitter" do
      expect(reply).to have(8).previous_tweets
    end

    it "persists all tweets in the database" do
      expect(reply.previous_tweet).to be_a Tweet
      expect(reply.previous_tweet).to be_persisted
    end

    it "saves an array of previous tweet ids for instant conversations" do
      expect(reply_tweet).to have(8).previous_tweet_ids
    end

    it "returns true" do
      expect(@conversation).to eq(true)
    end
  end
end
