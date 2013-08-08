class Status < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  belongs_to :twitter_account

  before_validation :generate_token, if: :new_record?

  validates :project,
            :text,
            :token,
            :twitter_account,
            presence: true

  def to_param
    token
  end

  ##
  # Is a Reply?

  def reply?
    !!in_reply_to_status_id
  end

  def previous_tweet
    return unless reply?
    @previous_tweet ||= find_or_fetch_tweet(in_reply_to_status_id)
  end

  ##
  # Publishing

  def publish!
    raise self.to_yaml
  end

  private

  # Generates a token without overriding the existing one
  def generate_token
    return true unless new_record?

    begin
      self[:token] = Tokenizer.random_token(4)
    end while Status.exists?(token: self[:token])
  end

  private

  ##
  # Find or fetch a tweet

  # Returns a tweet record
  def find_or_fetch_tweet(twitter_id)
    find_tweet(twitter_id) || fetch_tweet(twitter_id)
  end

  # Returns the tweet record from the database if present
  def find_tweet(twitter_id)
    project.tweets.where(twitter_id: twitter_id).first
  end

  # Fetches the given status from Twitter
  # Returns the persisted tweet record
  def fetch_tweet(twitter_id)
    status = twitter_client.status(twitter_id)

    # Avoid referencing random twitter account
    tweet = TweetMaker.from_twitter(status, project: project, state: :conversation)

  rescue Twitter::Error => e
    @runs ||= 0 and @runs += 1

    # Statuses may be deleted voluntarily by the author
    if e.is_a? Twitter::Error::NotFound
      return nil if @runs > 2
    else
      raise e if @runs > 3
    end

    # Retry using a different random Twitter account
    sleep 1 and retry
  end

  def twitter_client
    RandomTwitterClient.new
  end
end
