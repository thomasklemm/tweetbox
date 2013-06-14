class Status
  include Reformer
  include Draper::Decoratable

  attribute :project, Project
  attribute :user, User
  attribute :twitter_account_id, Integer
  attribute :text, String

  attribute :in_reply_to_status_id, Integer

  attr_reader :reply_to_tweet
  attr_reader :posted_tweet

  validates :project,
            :user,
            :twitter_account_id,
            :text, presence: true

  # Note: The order the params are being passed makes a difference
  def in_reply_to_status_id=(twitter_id)
    super
    @reply_to_tweet = project.tweets.where(twitter_id: twitter_id).first! if twitter_id.present?
  end

  def reply?
    !!in_reply_to_status_id
  end

  def twitter_account
    @twitter_account ||= twitter_account!
  end

  def save
    # Generates code and posted text
    if valid? && valid_tweet?
      post!
      true
    else
      false
    end
  end

  private

  ##
  # Prerequisites

  def twitter_account!
    (twitter_account_id && project.twitter_accounts.find(twitter_account_id)) || reply_to_tweet.try(:twitter_account)
  end

  def valid_tweet?
    !Twitter::Validation.tweet_invalid?(posted_text)
  end

  def code
    @code ||= RandomCode.new.code(8)
  end

  def posted_text
    @posted_text ||= posted_text!
  end

  def posted_text!
    return text if tweet_length(text) <= 140

    virtual_text = text.slice(0, 225)
    parts = [virtual_text, ellipsis_and_public_url]

    while tweet_length(parts.join) > 140
      parts = [virtual_text.slice(0, -2), ellipsis_and_public_url]
    end

    parts.join
  end

  def tweet_length(text)
    Twitter::Validation.tweet_length(text)
  end

  def ellipsis_and_public_status_url
    "...\n#{ public_url }"
  end

  def public_status_url
    "http://tweetbox.dev/tweets/#{ twitter_account.screen_name }/#{ code }"
  end

  ##
  # Posting

  # Returns the posted tweet
  def post!
    status = post_status
    tweet = create_posted_tweet(status)

    build_conversation_history(tweet)
    create_events

    tweet
  end

  def post_status
    twitter_account.client.update(posted_text, post_status_options)
  end

  def post_status_options
    reply? ? { in_reply_to_status_id: in_reply_to_status_id  } : {}
  end

  def create_posted_tweet(status)
    @posted_tweet = project.create_tweet_from_twitter(status, twitter_account: twitter_account, state: :posted)
  end

  # Builds from tweets in the database, at least it should ;)
  def build_conversation_history(tweet)
    ConversationWorker.new.perform(tweet.id)
  end

  def create_events
    @posted_tweet.create_event(:post, user)
    @reply_to_tweet.try(:create_event, :post_reply, user)
  end
end
