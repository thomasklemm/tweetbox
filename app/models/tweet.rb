# == Schema Information
#
# Table name: tweets
#
#  author_id             :integer          not null
#  created_at            :datetime         not null
#  id                    :integer          not null, primary key
#  in_reply_to_status_id :integer
#  in_reply_to_user_id   :integer
#  previous_tweet_ids    :integer
#  project_id            :integer          not null
#  state                 :text
#  text                  :text
#  twitter_account_id    :integer          not null
#  twitter_id            :integer          not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_tweets_on_previous_tweet_ids         (previous_tweet_ids)
#  index_tweets_on_project_id                 (project_id)
#  index_tweets_on_project_id_and_author_id   (project_id,author_id)
#  index_tweets_on_project_id_and_state       (project_id,state)
#  index_tweets_on_project_id_and_twitter_id  (project_id,twitter_id) UNIQUE
#

class Tweet < ActiveRecord::Base
  include ActiveModel::Transitions
  # include Twitter::Urls

  belongs_to :project
  belongs_to :author
  # Allows us to fetch previous tweets through the same twitter account
  belongs_to :twitter_account

  has_many :events, dependent: :destroy

  # Validations
  validates :project, :author, :twitter_id, presence: true
  validates_uniqueness_of :twitter_id, scope: :project_id

  # States
  scope :incoming, -> { where(state: :incoming) }
  scope :resolved, -> { where(state: :resolved) }
  scope :posted,   -> { where(state: :posted) }

  # States and transitions
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

  def resolve_and_record!(user)
    resolve!
    create_event(:resolve, user)
  end

  # Use default account if the one used to retrieve the tweet is no longer present
  def twitter_account
    super.presence || project.default_twitter_account
  end

  # Loads and memoizes the tweet's previous tweets
  # from the array of cached previous tweet ids
  def previous_tweets(reload=false)
    reload ? previous_tweets! : @previous_tweets ||= previous_tweets!
  end

  # Returns the previous tweet from the database
  # or instructs the ConversationWorker to fetch it from Twitter
  def previous_tweet
    return unless in_reply_to_status_id.present?

    previous_tweet = project.tweets.where(twitter_id: in_reply_to_status_id).first

    # Fetch previous tweet and whole conversation if tweets are not in the database already
    ConversationWorker.perform_async(self.id) if previous_tweet.blank?

    previous_tweet
  end

  # Loads and memoizes the tweet's future tweets
  def future_tweets(reload=false)
    reload ? future_tweets! : @future_tweets ||= future_tweets!
  end

  def conversation_with_author
    author_id = author.twitter_id
    recipient_id = in_reply_to_user_id

    return unless author_id && recipient_id

    (conversation_tweets(author_id, recipient_id) + conversation_tweets(recipient_id, author_id)).uniq.sort_by(&:created_at)
  end

  def conversation_tweets(first_user_id, second_user_id)
    project.tweets.where(in_reply_to_user_id: first_user_id).joins(:author).where(authors: {twitter_id: second_user_id}).to_a
  end

  def conversation(reload=false)
    reload ? conversation! : @conversation ||= conversation!
  end

  def conversation!
    @conversation = (previous_tweets.to_a + [self] + future_tweets.to_a).flatten.sort_by(&:created_at).uniq
  end

  # Assigns a certain workflow state given a symbol or string
  # Knows about a whitelist of valid states
  def assign_state(state)
    state &&= state.try(:to_sym)
    return unless Tweet.available_states.include?(state)
    state == :conversation ? self.state ||= state : self.state = state
  end

  # Assigns the tweet's fields from a Twitter status object
  # Persists the changes to the database by saving the record
  # Returns the saved tweet record
  def update_fields_from_status(status)
    assign_fields_from_status(status)
    save && self
  end

  def create_event(kind, user)
    events.create!(kind: kind, user: user)
  end

  def to_param
    twitter_id
  end

  private

  # Assigns the tweet's fields from a Twitter status object
  # Returns the tweet record without saving it and persisting
  # the changes to the database
  def assign_fields_from_status(status)
    self.twitter_id = status.id
    self.text       = status.text # Twitter::Urls.expand(status.text, status.urls)
    self.created_at = status.created_at
    self.in_reply_to_status_id = status.in_reply_to_status_id
    self.in_reply_to_user_id   = status.in_reply_to_user_id
  end

  # Loads the previous tweets from the database
  def previous_tweets!
    @previous_tweets = self.class.where(twitter_id: previous_tweet_ids).sort_by(&:created_at) if previous_tweet_ids.present?
  end

  # Loads the future tweets from the database
  def future_tweets!
    @future_tweets = self.class.where('previous_tweet_ids && ARRAY[?]', self.twitter_id).sort_by(&:created_at)
  end

  # Callbacks
  after_commit :build_conversation, on: :create

  # Fetch previous tweets and cache previous tweet ids in the background
  def build_conversation
    ConversationWorker.perform_async(id)
  end
end
