# == Schema Information
#
# Table name: tweets
#
#  author_id             :integer
#  created_at            :datetime         not null
#  id                    :integer          not null, primary key
#  in_reply_to_status_id :integer
#  in_reply_to_user_id   :integer
#  project_id            :integer
#  text                  :text
#  twitter_id            :integer
#  updated_at            :datetime         not null
#  workflow_state        :text
#
# Indexes
#
#  index_tweets_on_author_id                  (author_id)
#  index_tweets_on_project_id                 (project_id)
#  index_tweets_on_project_id_and_twitter_id  (project_id,twitter_id) UNIQUE
#  index_tweets_on_twitter_id                 (twitter_id)
#  index_tweets_on_workflow_state             (workflow_state)
#

class Tweet < ActiveRecord::Base
  include Workflow

  belongs_to :project
  validates :project, presence: true

  belongs_to :author
  validates :author, presence: true

  scope :incoming, where(workflow_state: [:new, :open])
  scope :resolved, where(workflow_state: :closed)

  # Ensures uniquness of a tweet scoped to the project
  validates_uniqueness_of :twitter_id, scope: :project_id

  workflow do
    # New tweets that require a decision are marked as :new
    # Unless a different state is assigned, all tweets start as :new.
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

    # Tweets that have been fetched solely to build up conversation histories
    # can be marked with the :none state. They require no action, but an agent
    # may decide to open a case from them.
    state :none do
      event :open, transitions_to: :open
      event :close, transitions_to: :closed
    end
  end

  # Fetch missing tweets in the conversation from Twitter
  before_save :previous_tweets

  # Caches the resulting previous tweets
  def previous_tweets
    @previous_tweets ||= previous_tweets!
  end

  # Finds or fetches the previous tweet from Twitter if the tweet is a reply
  # Returns a tweet record
  def previous_tweet
    project.tweets.where(twitter_id: in_reply_to_status_id).first! if in_reply_to_status_id.present?
  rescue ActiveRecord::RecordNotFound
    project.get_previous_tweet(in_reply_to_status_id)
  end

  # Caches the resulting future tweets
  def future_tweets
    @future_tweets ||= future_tweets!
  end

  # Assigns a certain workflow state given a symbol or string
  # Knows about a whitelist of valid states
  def assign_state(state)
    state &&= state.to_s
    return unless ['new', 'open', 'closed', 'none'].include?(state)

    # TODO: Specs, think about real world
    if state == 'none'
      self.workflow_state = state unless workflow_state.present?
    else
      self.workflow_state = state
    end
  end

  # Assigns the tweet's fields from a Twitter status object
  # Persists the changes to the database by saving the record
  # Returns the tweet record
  def update_fields_from_status(status)
    assign_fields_from_status(status)
    # Note that the before_save callback fetching previous tweets kicks in
    save && self
  end

  private

  # Assigns the tweet's fields from a Twitter status object
  # Returns the tweet record without saving it and persisting
  # the changes to the database
  def assign_fields_from_status(status)
    self.twitter_id = status.id
    self.text       = status.text
    self.created_at = status.created_at
    self.in_reply_to_status_id = status.in_reply_to_status_id
    self.in_reply_to_user_id   = status.in_reply_to_user_id
  end


  # Returns an array of the previous tweets
  # if the tweet is a reply, otherwise returns an empty array
  def previous_tweets!
    tweets = []
    tweet = self

    # while tweet.previous_tweet
    #   tweets << tweet.previous_tweet
    #   tweet = previous_tweet
    # end

    tweets.sort_by(&:created_at)
  end

  # # Returns an array of the future tweets if the tweet has replies
  # def future_tweets!
  #   tweets = []
  #   tweet = self

  #   while tweet.future_tweet_records
  #     tweets << tweet.future_tweet_records
  #     tweet = future_tweet
  #   end

  #   tweets &&= tweets.flatten.uniq
  #   tweets.sort_by(&:created_at).reverse
  # end

  # # Returns an array of tweet records
  # def future_tweet_records
  #   project.tweets.where(in_reply_to_status_id: self.id).presence
  # end
end
