class Retweet
  include Reformer

  attribute :project, Project
  attribute :old_tweet, Tweet
  attribute :twitter_account_id, Integer
  attribute :user, User

  attr_reader :new_tweet

  validates :project,
            :old_tweet,
            :twitter_account_id,
            :user, presence: true

  def tweet=(tweet)
    self.old_tweet = tweet
  end

  def save
    if valid?
      post!
      true
    else
      false
    end
  end

  private

  def twitter_account
    @twitter_account ||= project.twitter_accounts.find(twitter_account_id) if twitter_account_id
  end

  def post!
    status = post_retweet
    create_new_tweet(status)
    create_events_on_tweets
    true
  end

  # Returns new Twitter status object
  def post_retweet
    response = twitter_account.client.retweet!(old_tweet.twitter_id)
    response.first.retweeted_status
  end

  # Creates a new tweet from the given Twitter status object and returns it
  def create_new_tweet(status)
    @new_tweet = project.create_tweet_from_twitter(status, state: :posted, twitter_account: twitter_account)
  end

  def create_events_on_tweets
    old_tweet.events.create!(kind: :retweet, user: user)
    new_tweet.events.create!(kind: :post, user: user)
  end
end
