class Retweet
  include Reformer

  attribute :project, Project
  attribute :old_tweet, Tweet
  attribute :twitter_account, TwitterAccount
  attribute :user, User

  attr_reader :new_tweet

  validates :project,
            :old_tweet,
            :twitter_account,
            :user, presence: true

  def initialize(project, tweet, user, opts={})
    self.project = project
    self.old_tweet = tweet
    self.user = user
    twitter_account_id = opts.fetch(:twitter_account_id) { raise 'Retweet.new requires a :twitter_account_id' }
    self.twitter_account = project.twitter_accounts.find(twitter_account_id)
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

  def post!
    status = post_retweet
    create_new_tweet(status)
    create_events_on_tweets
    true
  end

  # Returns new Twitter status object
  def post_retweet
    twitter_account.client.retweet!(old_tweet.twitter_id)
  end

  # Creates a new tweet from the given Twitter status object and returns it
  def create_new_tweet(status)
    @new_tweet = project.create_tweet_from_twitter(status, state: :retweeted, twitter_account: twitter_account)
  end

  def create_events_on_tweets
    old_tweet.events.create!(kind: :retweeted, user: user)
    new_tweet.events.create!(kind: :retweeted, user: user)
  end
end
