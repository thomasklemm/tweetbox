# == Schema Information
#
# Table name: projects
#
#  account_id :integer
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  name       :text
#  updated_at :datetime         not null
#
# Indexes
#
#  index_projects_on_account_id  (account_id)
#

class Project < ActiveRecord::Base
  belongs_to :account
  validates :account, presence: true

  has_many :permissions, dependent: :destroy
  has_many :users, through: :permissions

  validates :name, presence: true

  has_many :twitter_accounts, dependent: :destroy
  has_many :searches # dependent on existence of twitter account

  has_many :tweets, dependent: :destroy
  has_many :authors, dependent: :destroy

  after_create :setup_permissions
  after_update :update_permissions

  def self.visible_to(user)
    where(id: user.project_ids)
  end

  def self.by_name
    order('projects.name')
  end

  def has_member?(user)
    permissions.
      joins(:membership).
      exists?(memberships: { user_id: user.id })
  end

  # We have to define there here instead of mixing them in,
  # because ActiveRecord does the same.

  def user_ids=(new_user_ids)
    @new_user_ids = new_user_ids.reject { |user_id| user_id.blank? }
  end

  def users
    if new_record?
      permissions.map { |permission| permission.membership.user }
    else
      permissions.includes(:user).map { |permission| permission.user }
    end
  end

  def user_ids
    users.map(&:id)
  end

  # Returns an instance of Twitter::Client instanciated with credentials
  # of a random one of the twitter accounts associated with the project
  # def random_twitter_client
  #   twitter_account = twitter_accounts.sample
  #   twitter_account.client
  # end

  # Create one or many tweet records
  # from Twitter status objects
  # Returns an array of tweet records
  def create_tweets_from_twitter(statuses, options={})
    statuses &&= [statuses].flatten.reverse
    twitter_account = options.fetch(:twitter_account)
    state = options.fetch(:state, :none)

    statuses.map { |status| create_tweet_from_twitter(status, twitter_account, state) }
  end

  private

  # Creates a tweet record from a Twitter status object
  # Returns a tweet record
  def create_tweet_from_twitter(status, twitter_account, state)
    author = find_or_create_author(status)
    tweet = find_or_create_tweet(status, author, twitter_account, state)
    # REWORK THIS!
    # add unless state == :none
    # tweet.delay.fetch_and_update_previous_tweet_ids(twitter_account)
    tweet
  end

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

  def setup_permissions
    @new_user_ids ||= []
    @new_user_ids += admin_user_ids
    removed_user_ids = self.user_ids - @new_user_ids
    added_user_ids = @new_user_ids - self.user_ids

    permissions.where(user_id: removed_user_ids).destroy_all
    added_user_ids.each do |added_user_id|
      membership = account.memberships.where(user_id: added_user_id).first
      permissions.create! do |permission|
        permission.membership_id = membership.id
      end
    end
  end

  def update_permissions
    setup_permissions if @new_user_ids
  end

  def admin_user_ids
    account.
      memberships.
      where(admin: true).
      select(:user_id).
      map(&:user_id)
  end
end
