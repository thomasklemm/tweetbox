describe TweetMaker do
  include_context 'signup and twitter account'

  describe ".many_from_twitter" do
    it "requires a :project" do
      expect{ TweetMaker.many_from_twitter([Object.new]) }.to raise_error(RuntimeError, 'Requires a :project')
    end

    it "requires a :state" do
      expect{ TweetMaker.many_from_twitter([Object.new], project: Object.new) }.to raise_error(RuntimeError, 'Requires a :state')
    end

    it "creates the given tweets and returns an array of tweet records" do
      VCR.use_cassette('user_timelines/simyo') do
        statuses = twitter_account.client.user_timeline('simyo', count: 5)
        tweets = TweetMaker.many_from_twitter(statuses, project: project, twitter_account: twitter_account, state: :incoming)

        status = statuses.first
        tweet = tweets.first

        # Return value
        expect(tweets).to be_an Array

        expect(tweet).to be_a Tweet
        expect(tweet).to be_persisted

        # Associations
        expect(tweet.project).to eq project
        expect(tweet.twitter_account).to eq twitter_account
        expect(tweet.state).to eq :incoming

        # Fields
        expect(tweet.twitter_id).to eq(status.id)
        expect(tweet.text).to_not eq(status.text) # has expanded urls
        expect(tweet.text).to eq(Tweet.new.expand_urls(status.text, status.urls))
        expect(tweet.in_reply_to_user_id).to eq(status.in_reply_to_user_id)
        expect(tweet.in_reply_to_status_id).to eq(status.in_reply_to_status_id)
        expect(tweet.source).to eq(status.source)
        expect(tweet.lang).to eq(status.lang)
        expect(tweet.retweet_count).to eq(status.retweet_count)
        expect(tweet.favorite_count).to eq(status.favorite_count)
        expect(tweet.created_at).to eq(status.created_at)

        expect{ TweetMaker.many_from_twitter(statuses, project: project, state: :incoming) }.to_not raise_error
      end
    end
  end

  describe ".from_twitter" do
    it "requires a :project" do
      expect{ TweetMaker.from_twitter(Object.new) }.to raise_error(RuntimeError, 'Requires a :project')
    end

    it "requires a :state" do
      expect{ TweetMaker.from_twitter(Object.new, project: Object.new) }.to raise_error(RuntimeError, 'Requires a :state')
    end

    it "creates the given tweet and returns a tweet record" do
      VCR.use_cassette('statuses/351779153646858241') do
        status = twitter_account.client.status('351779153646858241')
        tweet = TweetMaker.from_twitter(status, project: project, twitter_account: twitter_account, state: :incoming)

        # Return value
        expect(tweet).to be_a Tweet
        expect(tweet).to be_persisted

        # Associations
        expect(tweet.project).to eq project
        expect(tweet.twitter_account).to eq twitter_account
        expect(tweet.state).to eq :incoming

        # Fields
        expect(tweet.twitter_id).to eq(status.id)
        expect(tweet.text).to_not eq(status.text) # has expanded urls
        expect(tweet.text).to eq(Tweet.new.expand_urls(status.text, status.urls))
        expect(tweet.in_reply_to_user_id).to eq(status.in_reply_to_user_id)
        expect(tweet.in_reply_to_status_id).to eq(status.in_reply_to_status_id)
        expect(tweet.source).to eq(status.source)
        expect(tweet.lang).to eq(status.lang)
        expect(tweet.retweet_count).to eq(status.retweet_count)
        expect(tweet.favorite_count).to eq(status.favorite_count)
        expect(tweet.created_at).to eq(status.created_at)

        expect{ TweetMaker.from_twitter(status, project: project, state: :incoming) }.to_not raise_error

        # Author
        user = status.user
        author = tweet.author

        expect(author).to be_an Author
        expect(author).to be_persisted

        expect(author.twitter_id).to eq(user.id)
        expect(author.screen_name).to eq(user.screen_name)

        expect{ AuthorMaker.from_twitter(user, project: project) }.to_not raise_error
      end
    end
  end
end
