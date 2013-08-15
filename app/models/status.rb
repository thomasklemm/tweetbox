class Status < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  belongs_to :twitter_account

  has_one :tweet

  before_validation :generate_token, if: :new_record?

  validates :project,
            :text,
            :token,
            :twitter_account,
            :user,
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


  # Is a Long Status?

  def long_status?
    length_on_twitter(text) > 140
  end

  def short_text
    @short_text ||= short_text!
  end

  def short_text_length
    length_on_twitter(short_text)
  end

  def text_length
    length_on_twitter(text)
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

    # Save here already in case any of the later steps fail
    # in order to prevent a duplicate tweet on Twitter (would raise a Twitter::Error::Forbidden)
    self.save!

    # Create new posted tweet
    # and build conversation
    tweet = TweetMaker.from_twitter(status, project: project, twitter_account: twitter_account, state: :posted)

    # Link tweet and status together
    tweet.status = self

    # Create :post event on new tweet
    # and :post_reply event on previous tweet
    tweet.create_event(:post, user)
    previous_tweet.try(:create_event, :post_reply, user)

    self.save! and tweet.save!
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

  def short_text!
    return text if length_on_twitter(text) <= 140

    html = TweetPipeline.new(text).to_html
    text = Sanitize.clean(html)

    parts = [ text[0..200], "... #{ public_status_url }" ]
    parts[0] = parts[0][0..-2] until length_on_twitter(parts.join) <= 140
    parts.join
  end

  def length_on_twitter(text)
    Twitter::Validation.tweet_length(text)
  end

  def public_status_url
    Rails.application.routes.url_helpers.public_status_url(token)
  end
end
