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
#  text                  :text
#  twitter_account_id    :integer          not null
#  twitter_id            :integer          not null
#  updated_at            :datetime         not null
#  workflow_state        :text             not null
#
# Indexes
#
#  index_tweets_on_previous_tweet_ids             (previous_tweet_ids)
#  index_tweets_on_project_id                     (project_id)
#  index_tweets_on_project_id_and_author_id       (project_id,author_id)
#  index_tweets_on_project_id_and_twitter_id      (project_id,twitter_id) UNIQUE
#  index_tweets_on_project_id_and_workflow_state  (project_id,workflow_state)
#

class Tweet < ActiveRecord::Base
  include Workflow

  belongs_to :project
  validates :project, presence: true

  belongs_to :author
  validates :author, presence: true

  # Allows us to fetch previous tweets through the same twitter account
  belongs_to :twitter_account
  validates :twitter_account, presence: true

  # Tweet actions and events
  has_many :actions, readonly: true

  # Tweet actions
  has_many :replies, dependent: :restrict
  has_many :comments, dependent: :restrict
  has_many :retweets, dependent: :restrict
  has_many :favorites, dependent: :restrict

  # Tweet events
  has_many :transitions, dependent: :destroy
  has_many :events, dependent: :destroy

  # States
  scope :incoming, where(workflow_state: :new)
  scope :replying, where(workflow_state: :open)
  scope :resolved, where(workflow_state: :closed)

  # Ensures uniquness of a tweet scoped to the project
  validates_uniqueness_of :twitter_id, scope: :project_id

  workflow do
    # Tweets that have been fetched solely to build up conversation histories
    # can be marked with the :none state. They require no action, but an agent
    # may decide to open a case from them.
    # Unless a different state is assigned, all tweets are marked as :none.
    state :none do
      event :open, transitions_to: :open
      event :close, transitions_to: :closed
    end

    # New tweets that require a decision are marked as :new
    state :new do
      event :open, transitions_to: :open
      event :close, transitions_to: :closed
    end

    # Open tweets require an action such as a reply. The :open state
    # marks in essence open cases on our helpdesk.
    state :open do
      event :open, transitions_to: :open
      event :close, transitions_to: :closed
    end

    # Closed tweets are tweets that have been dealt with. They may have
    # marked as :closed after a reply has been sent, or simply been appreciated
    # and marked as :closed without requiring an action.
    state :closed do
      event :open, transitions_to: :open
      event :close, transitions_to: :closed
    end
  end

  # Callbacks
  after_commit :build_conversation, on: :create

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
    @conversation = (previous_tweets.to_a + [self] + future_tweets.to_a + conversation_with_author.to_a).flatten.sort_by(&:created_at).uniq
  end

  # Assigns a certain workflow state given a symbol or string
  # Knows about a whitelist of valid states
  def assign_state(state)
    state &&= state.to_s
    return unless %w(none new open closed).include?(state)

    # Assigns known states, but only assign none state if there isn't already a state present
    state == 'none' ? self.workflow_state ||= state : self.workflow_state = state
  end

  # Assigns the tweet's fields from a Twitter status object
  # Persists the changes to the database by saving the record
  # Returns the saved tweet record
  def update_fields_from_status(status)
    assign_fields_from_status(status)
    save && self
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
    self.text       = rewrite_urls_in_text(status)
    self.created_at = status.created_at
    self.in_reply_to_status_id = status.in_reply_to_status_id
    self.in_reply_to_user_id   = status.in_reply_to_user_id
  end

  # Returns the tweet text with urls rewritten to their target
  def rewrite_urls_in_text(status)
    Twitter::Rewriter.rewrite_entities(status.text, status.urls) { |url| url.expanded_url }
  end

  # Loads the previous tweets from the database
  def previous_tweets!
    @previous_tweets = self.class.where(twitter_id: previous_tweet_ids).sort_by(&:created_at) if previous_tweet_ids.present?
  end

  # Loads the future tweets from the database
  def future_tweets!
    @future_tweets = self.class.where('previous_tweet_ids && ARRAY[?]', self.twitter_id).sort_by(&:created_at)
  end

  # Fetch previous tweets and cache previous tweet ids in the background
  def build_conversation
    ConversationWorker.perform_async(self.id)
  end
end
