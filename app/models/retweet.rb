class Retweet
  include Virtus
  include ActiveAttr::BasicModel

  attribute :project, Project
  attribute :user, User
  attribute :twitter_account_id, Integer
  attribute :status_id, Integer

  validates :project,
            :user,
            :twitter_account_id,
            :status_id, presence: true

  attr_reader :new_tweet

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
    @twitter_account ||= project.twitter_accounts.find(twitter_account_id)
  end

  def old_tweet
    @old_tweet ||= project.tweets.where(twitter_id: status_id).first!
  end

  def post!
    status = post_retweet
    create_new_tweet(status)
    create_events_on_tweets
    true
  end

  def post_retweet
    twitter_account.client.retweet!(status_id)
  end

  def create_new_tweet(status)
    @new_tweet = project.create_tweet_from_twitter(status, state: :retweeted, twitter_account: twitter_account, retweet: true)
  end

  def create_events_on_tweets
    old_tweet.events.create!(kind: :retweeted, user: user)
    new_tweet.events.create!(kind: :retweeted, user: user)
  end
end
