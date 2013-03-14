# == Schema Information
#
# Table name: tweets
#
#  author_id             :integer
#  conversation_id       :integer
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
#  index_tweets_on_conversation_id            (conversation_id)
#  index_tweets_on_project_id                 (project_id)
#  index_tweets_on_project_id_and_twitter_id  (project_id,twitter_id) UNIQUE
#  index_tweets_on_twitter_id                 (twitter_id)
#  index_tweets_on_workflow_state             (workflow_state)
#

class Tweet < ActiveRecord::Base
  include Workflow

  # Project
  belongs_to :project
  validates :project, presence: true

  # Twitter Id
  validates_uniqueness_of :twitter_id, scope: :project_id

  # Author
  belongs_to :author
  validates :author, presence: true

  # Conversation
  belongs_to :conversation

  # Workflow with states, events and transitions
  workflow do
    # Tweets start in the :new state
    state :new do
      event :open, transitions_to: :open
      event :close, transitions_to: :closed
    end
    state :open do
      event :open, transitions_to: :open
      event :close, transitions_to: :closed
    end
    state :closed do
      event :open, transitions_to: :open
      event :close, transitions_to: :closed
    end

    # Conversation state marks tweets that have been pulled in
    # purely to build up the conversations, and that require no action
    state :conversation
  end

  # Create one to many tweets from twitter statuses
  def self.from_twitter(statuses, options={})
    statuses &&= [statuses].flatten.reverse
    project = options.fetch(:project)
    source = options.fetch(:source)

    statuses.map { |status| create_tweet_from_twitter(project, status, source) }
  end

  def self.create_tweet_from_twitter(project, status, source)
    author = Author.find_or_create_author(project, status)
    tweet = self.find_or_create_tweet(project, status, author, source)
  end

  def self.find_or_create_tweet(project, status, author, source)
    tweet = project.tweets.where(twitter_id: status.id).first_or_initialize
    tweet.author = author
    tweet.assign_fields_and_save(status, source)
  end

  def assign_fields_and_save(status, source)
    self.assign_fields_from_status(status)
    self.assign_workflow_state(source)

    self.build_conversation

    self.save && self
  end

  def assign_fields_from_status(status)
    self.twitter_id = status.id
    self.text       = status.text
    self.created_at = status.created_at
    self.in_reply_to_status_id = status.in_reply_to_status_id
    self.in_reply_to_user_id   = status.in_reply_to_user_id
  end

  def assign_workflow_state(source)
    source == :building_conversations and self.workflow_state = :conversation
  end

  def build_conversation
    # Only create a conversation if this tweet is a reply
    in_reply_to_status_id.present? or return false

    previous_tweet = find_or_create_previous_tweet(in_reply_to_status_id)

    if previous_tweet.conversation.present?
      self.conversation = previous_tweet.conversation
    else
      conversation = project.conversations.create!
      previous_tweet.conversation = conversation
      previous_tweet.save

      self.conversation = conversation
    end
    self.save
  end

  private

  def find_or_fetch_previous_tweet(twitter_id)
    tweet = project.tweets.find_by_twitter_id!(twitter_id)
  rescue ActiveRecord::RecordNotFound
    tweet = fetch_previous_tweet(twitter_id)
  end

  def fetch_previous_tweet(twitter_id)
    status = project.twitter_client.status(twitter_id)
    Tweet.from_twitter(status, project: project, source: :building_conversations)
    tweet = project.tweets.find_by_twitter_id!(twitter_id) # REVIEW: redundant
  end
end
