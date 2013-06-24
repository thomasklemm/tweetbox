class Status
  include Reformer
  include Draper::Decoratable

  attribute :project, Project
  attribute :user, User
  attribute :twitter_account, TwitterAccount

  attribute :full_text, String
  attribute :posted_text, String

  attribute :posted_tweet, Tweet
  attribute :code, Code

  validates :project,
            :user,
            :twitter_account,
            :full_text,
            :posted_text, presence: true

  validate :posted_text_must_be_valid_tweet

  def twitter_account_id=(twitter_account_id)
    self.twitter_account = project.twitter_accounts.find(twitter_account_id)
  end

  ##
  # Reply stuff

  attribute :in_reply_to_status_id, Integer
  attribute :reply_to_tweet, Tweet

  # NOTE: Params are being initialized in the order they are passed, so pass project first
  def in_reply_to_status_id=(twitter_id)
    super
    self.reply_to_tweet = project.tweets.where(twitter_id: twitter_id).first! if twitter_id.present?
  end

  def in_reply_to_status_id
    super || reply_to_tweet.try(:twitter_id)
  end

  def reply?
    in_reply_to_status_id.present?
  end

  def create_start_reply_event
    reply_to_tweet.try(:create_event, :start_reply, user)
  end

  def save
    generate_posted_text

    if valid?
      post!
      true
    else
      false
    end
  end

  private

  ##
  # Posted text

  def generate_posted_text
    return if posted_text.present?

    self.posted_text = if tweet_length(full_text) <= 140 && valid_tweet?(full_text)
      full_text
    else
      generate_code

      elements = [full_text[0..200], ellipsis_and_public_url]
      elements[0] = elements[0][0..-2] until tweet_length(elements.join) <= 140
      elements.join
    end
  end

  def public_url
    "http://lvh.me:7000/tweets/#{ twitter_account.screen_name }/#{ code.id }"
  end

  def ellipsis_and_public_url
    "... #{ public_url }"
  end

  def generate_code
    self.code ||= Code.create!
  end

  ##
  # Validations

  def tweet_length(text)
    Twitter::Validation.tweet_length(text)
  end

  def valid_tweet?(text)
    !Twitter::Validation.tweet_invalid?(text)
  end

  def posted_text_must_be_valid_tweet
    unless valid_tweet?(posted_text)
      errors.add(:posted_text, 'must be valid text')
    end
  end

  ##
  # Posting the status

  # Returns the posted tweet
  def post!
    status = post_status
    self.posted_tweet = create_posted_tweet(status)

    link_code_with_posted_tweet
    build_conversation_history_on_posted_tweet
    create_events_on_tweets

    posted_tweet
  end

  def post_status
    twitter_account.client.update(posted_text, post_status_options)
  end

  # Status will be a reply on Twitter only if :in_reply_to_status_id is present in options
  def post_status_options
    options = {}
    options[:in_reply_to_status_id] = in_reply_to_status_id if reply?
    options
  end

  def create_posted_tweet(status)
    project.create_tweet_from_twitter(status, twitter_account: twitter_account, state: :posted)
  end

  def link_code_with_posted_tweet
    if code
      self.code.tweet = posted_tweet and self.code.save!
    end
  end

  # Build conversation history at this very moment from the database
  def build_conversation_history_on_posted_tweet
    ConversationWorker.new.perform(posted_tweet.id)
  end

  # Create :post and :post_reply events
  def create_events_on_tweets
    posted_tweet.create_event(:post, user)
    reply_to_tweet.try(:create_event, :post_reply, user)
  end
end
