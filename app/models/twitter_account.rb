# == Schema Information
#
# Table name: twitter_accounts
#
#  auth_scope            :text
#  created_at            :datetime         not null
#  description           :text
#  get_home              :boolean          default(TRUE)
#  get_mentions          :boolean          default(TRUE)
#  id                    :integer          not null, primary key
#  location              :text
#  max_home_tweet_id     :integer
#  max_mentions_tweet_id :integer
#  name                  :text
#  profile_image_url     :text
#  project_id            :integer
#  screen_name           :text
#  token                 :text             not null
#  token_secret          :text             not null
#  twitter_id            :integer          not null
#  uid                   :text             not null
#  updated_at            :datetime         not null
#  url                   :text
#
# Indexes
#
#  index_twitter_accounts_on_project_id  (project_id)
#  index_twitter_accounts_on_twitter_id  (twitter_id) UNIQUE
#

class TwitterAccount < ActiveRecord::Base
  belongs_to :project
  validates :project, presence: true

  # Only destroy a twitter account if no search is associated
  has_many :searches, dependent: :restrict

  # Each twitter account can be associated with only one project
  validates :twitter_id, presence: true, uniqueness: true

  # Credentials for authenticating with Twitter
  validates :uid, :token, :token_secret, presence: true

  # The authorization scope of the stored credentials
  validates :auth_scope, inclusion: { in: %w(read write messages) }

  def at_screen_name
    "@#{ screen_name }"
  end

  def destroyable?
    searches.empty?
  end

  # Returns a Twitter::Client instance for the twitter account
  def twitter_client
    Twitter::Client.new(
      oauth_token: token,
      oauth_token_secret: token_secret
    )
  end

  alias_method :client, :twitter_client

  # Create or update existing Twitter account
  # Returns twitter account record
  def self.from_omniauth(project, auth, auth_scope)
    t = project.twitter_accounts.where(uid: auth.uid).first_or_initialize # uid cannot change

    # Store credentials
    t.token        = auth.credentials.token   # can change, e.g. by changing access level...
    t.token_secret = auth.credentials.secret  #  ...or by revoking and reauthorizing access

    # Assign twitter authentcation scope for the provided credentials
    t.assign_auth_scope(auth_scope)

    # Assign user info
    t.assign_twitter_account_info(auth)

    # Save and return twitter account
    t.save! && t
  end

  # Assign user infos for authenticating twitter account
  # from omniauth auth hash
  def assign_twitter_account_info(auth)
    user = auth.extra.raw_info
    self.twitter_id  = user.id
    self.name        = user.name
    self.screen_name = user.screen_name
    self.location    = user.location
    self.description = user.description
    self.url         = user.url
    self.profile_image_url = user.profile_image_url_https
    self
  end

  # Assign the matching auth scope for the stored credentials
  def assign_auth_scope(auth_scope)
    case auth_scope.to_s
      when 'read'            then self.auth_scope = 'read'
      when 'read_and_write'  then self.auth_scope = 'write'
      when 'direct_messages' then self.auth_scope = 'messages'
      else raise "TwitterAccount#assign_auth_scope: Please provide a valid Twitter auth scope."
      end
  end

  def update_stats!(type, new_max_tweet_id)
    case type.to_s
    when 'mentions'
      self.max_mentions_tweet_id = new_max_tweet_id if new_max_tweet_id.to_i > max_mentions_tweet_id.to_i
    when 'home'
      self.max_home_tweet_id = new_max_tweet_id     if new_max_tweet_id.to_i > max_home_tweet_id.to_i
    else
      raise StandardError, "Please provide a valid type: #{ type }"
    end

    self.save!
  end

  after_commit :schedule_home_and_mentions, on: :create

  private

  # Fetch tweets asynchronously for the first time immediately after twitter account creation
  def schedule_home_and_mentions
    TwitterWorker.perform_async(:home, twitter_account_id: self.id)
    TwitterWorker.perform_in(30.seconds, :mentions, twitter_account_id: self.id)
  end
end
