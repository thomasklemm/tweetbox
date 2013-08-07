class Tweet < ActiveRecord::Base
  include ActiveModel::Transitions
  include UrlExpander

  belongs_to :project
  belongs_to :author
  belongs_to :twitter_account # used to fetch the tweet

  # Events
  has_many :events, -> { order(created_at: :asc) }, dependent: :destroy

  # Validations
  validates :project, :author, :twitter_id, :state, presence: true
  validates_uniqueness_of :twitter_id, scope: :project_id

  # Scopes
  scope :incoming, -> { where(state: :incoming).by_date.include_conversation }
  scope :resolved, -> { where(state: :resolved).by_date.include_conversation }
  scope :posted,   -> { where(state: :posted).by_date.include_conversation }

  scope :by_date, -> { order(created_at: :desc) }

  scope :include_conversation, -> { includes(:author, { events: :user }) }

  ##
  # Reply and previous tweet

  def reply?
    !!in_reply_to_status_id
  end

  def previous_tweet_id
    in_reply_to_status_id
  end

  def previous_tweet
    return unless reply?
    @previous_tweet ||= Conversation.new(self).previous_tweet
  end

  # Returns an array of tweet records
  def previous_tweets
    return unless reply?
    @previous_tweets ||= if previous_tweet_ids.present?
      cached_previous_tweets
    else
      previous_tweets!
    end
  end

  def previous_tweets!
    @previous_tweets = Conversation.new(self).previous_tweets if reply?
  end


  ##
  # Cached conversation

  def conversation
    @conversation ||= begin
      tweets = cached_previous_tweets.to_a + [ self ] + cached_future_tweets.to_a
      tweets.flatten.sort_by(&:created_at).uniq
    end
  end

  def cached_previous_tweets
    @previous_tweets ||= begin
      tweets = project.tweets.where(twitter_id: previous_tweet_ids).include_conversation
      tweets.sort_by(&:created_at).uniq
    end
  end

  def cached_future_tweets
    @future_tweets ||= begin
      tweets = project.tweets.where('previous_tweet_ids && ARRAY[?]', twitter_id).include_conversation
      tweets.sort_by(&:created_at).uniq
    end
  end


  ##
  # States, events and transitions
  #
  # Defined states (initial state: :conversation)
  # - :conversation marks tweets that have been pulled in to build up conversations
  # - :incoming marks incoming tweets that require a decision
  # - :resolved marks tweets that have received the required actions
  # - :posted marks tweet posted through Tweetbox, those are quite awesome!

  state_machine initial: :conversation do
    state :conversation
    state :incoming
    state :resolved
    state :posted

    event :activate do
      transitions to: :incoming, from: [:conversation, :incoming, :resolved]
    end

    event :resolve do
      transitions to: :resolved, from: [:incoming, :resolved]
    end
  end

  def resolve!(user)
    resolve and create_event(:resolve, user)
  end

  def create_event(kind, user)
    events.create!(kind: kind, user: user)
  end


  ##
  # Background jobs

  # Fetch conversation from Twitter after tweet creation
  after_commit :fetch_conversation_async, on: :create

  def fetch_conversation_async
    ConversationWorker.perform_async(self.id) if reply?
  end


  ##
  # Field assigments

  # Assigns the tweet's fields from a Twitter status object
  # Returns the tweet record without saving it and persisting
  # the changes to the database
  def assign_fields(status)
    self.text = expand_urls(status.text, status.urls)
    self.in_reply_to_user_id = status.in_reply_to_user_id
    self.in_reply_to_status_id = status.in_reply_to_status_id
    self.source = status.source
    self.lang = status.lang
    self.retweet_count = status.retweet_count
    self.favorite_count = status.favorite_count
    self.created_at = status.created_at
    self
  end

  # Assigns a certain workflow state given a symbol or string
  # Knows about a whitelist of valid states
  def assign_state(state)
    state &&= state.try(:to_sym)
    raise "Unknown state: #{ state }" unless Tweet.available_states.include?(state)

    case state
    when :conversation then self.state ||= state # do not override existing states with :conversation state
    else self.state = state
    end
  end


  ##
  # Misc

  # Url parameter
  def to_param
    twitter_id
  end
end
