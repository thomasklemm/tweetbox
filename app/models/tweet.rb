class Tweet < ActiveRecord::Base
  include ActiveModel::Transitions
  include UrlExpander

  belongs_to :project
  belongs_to :author

  # Twitter account
  # used to fetch the tweet (optional)
  belongs_to :twitter_account

  # Conversation
  has_many :previous_conversations,
            class_name: 'Conversation',
            foreign_key: :future_tweet_id,
            dependent: :destroy
  has_many :previous_tweets,
             -> { order(created_at: :asc).includes(:author) },
             through: :previous_conversations,
             source: :previous_tweet

  has_many :future_conversations,
            class_name: 'Conversation',
            foreign_key: :previous_tweet_id,
            dependent: :destroy
  has_many :future_tweets,
             -> { order(created_at: :asc).includes(:author) },
             through: :future_conversations,
             source: :future_tweet

  # Events
  has_many :events, -> { order(created_at: :asc).includes(:user) }, dependent: :destroy

  # Validations
  validates :project,
            :author,
            :twitter_id,
            :state,
            presence: true

  validates_uniqueness_of :twitter_id, scope: :project_id

  # Counter caches
  counter_culture :project
  counter_culture :project,
    column_name: ->(model) { "#{ model.state }_tweets_count" },
    column_names: {
      # [] => 'tweets_count',
      ["tweets.state = ?", 'incoming'] => 'incoming_tweets_count',
      ["tweets.state = ?", 'resolved'] => 'resolved_tweets_count',
      ["tweets.state = ?", 'posted'] => 'posted_tweets_count'
    }

  # Scopes
  scope :incoming, -> { where(state: :incoming).include_conversation }
  scope :resolved, -> { where(state: :resolved).include_conversation }
  scope :posted,   -> { where(state: :posted).include_conversation }

  scope :by_date, ->(direction=:asc) { order(created_at: direction) }

  scope :include_conversation, -> { includes(:project, :author, :events, :previous_tweets, :future_tweets) }


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
    @previous_tweet ||= ConversationService.new(self).previous_tweet
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

  def resolve_by!(user)
    resolve
    create_event(:resolve, user)
    save!
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
