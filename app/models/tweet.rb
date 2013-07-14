class Tweet < ActiveRecord::Base
  include ActiveModel::Transitions
  include UrlExpander

  belongs_to :project
  belongs_to :author
  belongs_to :twitter_account # used to fetch the tweet

  # Events
  has_many :events, dependent: :destroy

  # Validations
  validates :project, :author, :twitter_id, :state, presence: true
  validates_uniqueness_of :twitter_id, scope: :project_id

  # Scopes
  scope :incoming, -> { where(state: :incoming) }
  scope :resolved, -> { where(state: :resolved) }
  scope :posted,   -> { where(state: :posted) }

  scope :by_date, -> { order('created_at desc') }


  ##
  # Tweet creation

  # Returns an array of the persisted tweet records
  def self.many_from_twitter(statuses, opts={})
    statuses.map { |status| from_twitter(status, opts) }
  end

  # Returns the persisted tweet record
  def self.from_twitter(status, opts={})
    project = opts.fetch(:project) { raise 'Requires a :project' }
    # Keep Twitter account if already present when building conversation
    twitter_account ||= opts.fetch(:twitter_account, nil)
    state = opts.fetch(:state) { raise 'Requires a :state' }

    tweet = project.tweets.where(twitter_id: status.id).first_or_initialize
    tweet.author ||= Author.from_twitter(status.user, project: project)
    tweet.assign_fields_and_state(status, state)

    tweet.save! and tweet
  rescue ActiveRecord::RecordNotUnique
    retry
  end

  def assign_fields_and_state(status, state)
    assign_fields(status)
    assign_state(state)
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
    super and create_event(:resolve, user)
  end

  def create_event(kind, user)
    events.create!(kind: kind, user: user)
  end


  ##
  # Reply and previous tweet

  def reply?
    !!in_reply_to_status_id
  end

  def previous_tweet_id
    in_reply_to_status_id
  end

  def previous_tweet
    find_or_fetch_previous_tweet if reply?
  end


  ##
  # Background jobs

  # Fetch conversation from Twitter after tweet creation
  after_commit :lets_converse_async, on: :create

  def lets_converse_async
    Conversationalist.perform_async(self.id) if reply?
  end

  # Fetches the previous tweets from Twitter
  # and caches their ids in previous_tweet_ids
  def fetch_previous_tweets_and_cache_ids
    assign_previous_tweet_ids and self.save!
  end


  ##
  # Cached conversation

  def cached_conversation
    @conversation ||= begin
      tweets = cached_previous_tweets.to_a + [ self ] + cached_future_tweets.to_a
      tweets.flatten.sort_by(&:created_at).uniq
    end
  end

  def cached_previous_tweets
    @previous_tweets ||= begin
      tweets = project.tweets.where(twitter_id: previous_tweet_ids)
      tweets.sort_by(&:created_at)
    end
  end

  def cached_future_tweets
    @future_tweets ||= begin
      tweets = project.tweets.where('previous_tweet_ids && ARRAY[?]', twitter_id)
      tweets.sort_by(&:created_at)
    end
  end


  ##
  # Misc

  # Url parameter
  def to_param
    twitter_id
  end


  private

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
  # Previous tweet

  def find_or_fetch_previous_tweet
    find_or_fetch_tweet(previous_tweet_id) if reply?
  end

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
    status = TwitterAccount.random.client.status(twitter_id)

    # Avoid referencing random twitter account
    tweet = Tweet.from_twitter(status, project: project, state: :conversation)

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


  ##
  # Previous tweets

  def assign_previous_tweet_ids
    self.previous_tweet_ids = fetch_previous_tweets.map(&:twitter_id)
  end

  def fetch_previous_tweets
    return unless reply?

    tweet = self
    tweets = []

    while tweet.previous_tweet
      tweets << tweet.previous_tweet
      tweet = tweet.previous_tweet
    end

    tweets.compact.sort_by(&:created_at)
  end
end
