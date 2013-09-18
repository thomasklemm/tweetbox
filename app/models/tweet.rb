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

  # Tweet has been posted through Tweetbox,
  #   so a status is associated
  belongs_to :status

  # Validations
  validates :project,
            :author,
            :twitter_id,
            :state,
            presence: true

  validates_uniqueness_of :twitter_id, scope: :project_id

  # Scopes
  scope :incoming, -> { where(state: :incoming).include_conversation }
  scope :stream,   -> { where(state: [:incoming, :resolved]).include_conversation }
  scope :posted,   -> { where(state: :posted).include_conversation }

  scope :include_conversation, -> { includes(:author, previous_tweets: :author, future_tweets: :author)  }

  scope :by_date, ->(direction=:desc) { order(created_at: direction) }

  # Excludes the given twitter id
  # REVIEW: DO THESE SCOPES RETURN THE CORRECT TWEETS IF THERE ARE MORE THAN X AFTER MIN_ID, THAT IS:
  #   ARE ALL TWEETS RETURNED AND NONE SKIPPED?; RIGHT NOW UNLIMITED RESULTS ARE RETURNED IN THE CONTROLLER
  #   IF THE REQUEST IS AN AJAX REQUEST
  scope :max_id, ->(twitter_id) { where('twitter_id < ?', twitter_id) if twitter_id.present? }
  scope :min_id, ->(twitter_id) { where('twitter_id > ?', twitter_id) if twitter_id.present? }

  # Counter caches
  counter_culture :project
  counter_culture :project,
    column_name: ->(model) { "#{ model.state }_tweets_count" unless model.conversation? },
    column_names: {
      # [] => 'tweets_count',
      ["tweets.state = ?", 'incoming'] => 'incoming_tweets_count',
      ["tweets.state = ?", 'resolved'] => 'resolved_tweets_count',
      ["tweets.state = ?", 'posted']   => 'posted_tweets_count'
    }

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
  # Status

  # Does this tweet also have a status record in our database?
  def status
    @status ||= Status.find_by(twitter_id: self.twitter_id)
  end

  ##
  # States, events, transitions and activities
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

  def resolve!
    resolve and touch(:resolved_at) and save!
  end

  ##
  # Conversation

  def full_conversation
    @full_conversation ||= [*previous_tweets, self, *future_tweets]
  end

  after_commit :fetch_conversation, on: :create

  def fetch_conversation
    ConversationWorker.perform_async(self.id)
  end

  def push_replace_tweet
    TweetPusherWorker.perform_async(self.id)
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

  def resolution_time_in_seconds
    return unless resolved_at && created_at
    resolved_at - created_at
  end
end
