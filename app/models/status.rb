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
    @previous_tweet ||= TweetFinder.new(project, in_reply_to_status_id).find_or_fetch
  end

  ##
  # Publishing

  def published?
    !!twitter_id
  end

  def publish!
    return true if published?
    publish_status!
  end

  private

  # Generates a token without overriding the existing one
  def generate_token
    return true unless new_record?

    begin
      self[:token] = Tokenizer.random_token(6)
    end while Status.exists?(token: self[:token])
  end

  ##
  # Publishing

  def publish_status!
    status = twitter_account.client.update(short_text, publish_opts)

    # Assign the twitter id of the posted tweet
    # which also flags the status as published
    self.twitter_id = status.id

    # Create new posted tweet
    # and build conversation
    tweet = TweetMaker.from_twitter(status, project: project, twitter_account: twitter_account, state: :posted)
    ConversationWorker.new.perform(tweet.id)

    # Create :post event on new tweet
    # and :post_reply event on previous tweet
    tweet.create_event(:post, user)
    previous_tweet.try(:create_event, :post_reply, user)

    self.save!
  end

  # The posted status will be a reply on Twitter
  # only if :in_reply_to_status_id is present in publish_opts
  def publish_opts
    options = {}
    options[:in_reply_to_status_id] = in_reply_to_status_id if reply?
    options
  end

  ##
  # Short text

  def short_text
    return text if tweet_length(text) <= 140

    parts = [ text[0..200], "... #{ public_status_url }" ]
    parts[0] = parts[0][0..-2] until tweet_length(parts.join) <= 140
    parts.join
  end

  def tweet_length(text)
    Twitter::Validation.tweet_length(text)
  end

  def public_status_url
    Rails.application.routes.url_helpers.public_status_url(token)
  end
end
