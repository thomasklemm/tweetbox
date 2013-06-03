# == Schema Information
#
# Table name: projects
#
#  account_id :integer          not null
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  name       :text             not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_projects_on_account_id  (account_id)
#

class Project < ActiveRecord::Base
  belongs_to :account, counter_cache: true
  validates :account, presence: true

  has_many :permissions, dependent: :destroy
  has_many :memberships, through: :permissions
  has_many :users, through: :permissions

  has_many :twitter_accounts, dependent: :destroy
  has_many :searches # destroyed when twitter account is destroyed

  has_many :tweets, dependent: :destroy
  has_many :authors, dependent: :destroy

  validates :name, presence: true

  scope :by_name, -> { order('projects.name') }
  scope :visible_to, ->(user) { where(id: user.project_ids) }

  def has_member?(user)
    permissions.
      joins(:membership).
      exists?(memberships: { user_id: user.id })
  end

  # Create one or many tweet records
  # from Twitter status objects
  # Returns an array of tweet records
  def create_tweets_from_twitter(statuses, options={})
    statuses &&= [statuses].flatten.reverse
    statuses.map { |status| create_tweet_from_twitter(status, options) }
  end

  # Creates a tweet record from a Twitter status object
  # Returns a tweet record
  def create_tweet_from_twitter(status, options={})
    twitter_account = options.fetch(:twitter_account) { raise "Passing a :twitter_account is required" }
    state = options.fetch(:state, :none)

    author = find_or_create_author(status)
    tweet = find_or_create_tweet(status, author, twitter_account, state)
    tweet
  end

  # Finds the tweet record with the twitter_id among the project tweets
  # If it could not be found, it will be retrieved from twitter
  # Returns a tweet record or nil if the tweet could not be found on Twitter
  def find_or_fetch_tweet(twitter_id)
    tweets.where(twitter_id: twitter_id).first || fetch_tweet(twitter_id)
  end

  def writable_twitter_accounts
    twitter_accounts.writable
  end

  def default_twitter_account
    writable_twitter_accounts.try(:first)
  end

  def to_param
    "#{ id }-#{ name.parameterize }"
  end

  private

  # Finds or creates an author scoped to the current project
  # from a Twitter status object
  # Returns an author record
  def find_or_create_author(status)
    author = authors.where(twitter_id: status.user.id).first_or_initialize
    author.update_fields_from_status(status)
  end

  # Find or create a tweet record scoped to the current project
  # from a Twitter status object and associates the author record
  # Returns a saved tweet record
  def find_or_create_tweet(status, author, twitter_account, state)
    tweet = tweets.where(twitter_id: status.id).first_or_initialize

    tweet.author = author
    tweet.twitter_account = twitter_account
    tweet.assign_state(state)

    # Saves the record
    tweet.update_fields_from_status(status)
  end

  # Fetches the given twitter_id from Twitter
  # Returns a tweet record or nil when it could not be found
  def fetch_tweet(twitter_id)
    status = default_twitter_account.client.status(twitter_id)
    create_tweet_from_twitter(status, state: :none, twitter_account: twitter_accounts.first )
  rescue Twitter::Error::NotFound
    nil
  end
end
