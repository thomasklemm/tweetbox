class TwitterAccount < ActiveRecord::Base
  extend Enumerize

  ACCESS_SCOPES = %w(read write)

  belongs_to :project
  validates :project, presence: true

  # Only destroy a twitter account if no search is associated
  has_many :searches, dependent: :restrict_with_exception

  # Tweets retrieved with current twitter account
  has_many :tweets, dependent: :nullify

  # Each twitter account can be associated with only one project
  validates :twitter_id, presence: true, uniqueness: true

  # Credentials used for authenticating with Twitter
  validates :uid, :token, :token_secret, presence: true

  # Access scope
  # #access_scope.read? and #access_scope.write?
  # TwitterAccount.with_access_scope(:read) and TwitterAccount.with_access_scope(:read, :write)
  enumerize :access_scope, in: ACCESS_SCOPES

  def at_screen_name
    "@#{ screen_name }"
  end

  def default?
    project.default_twitter_account_id == self.id
  end

  def serialized_hash
    { id: id, screen_name: screen_name, name: name, profile_image_url: profile_image_url, at_screen_name: at_screen_name }
  end

  # Returns a Twitter::Client instance
  # with the credentials of the current twitter account
  def client
    Twitter::Client.new(
      oauth_token: token,
      oauth_token_secret: token_secret
    )
  end

  def self.random
    order("RANDOM()").first
  end

  # Create or update existing Twitter account
  # Returns twitter account record
  def self.from_omniauth(project, auth, access_scope)
    twitter_account = project.twitter_accounts.where(uid: auth.uid).first_or_initialize # uid cannot change
    twitter_account.update_from_omniauth(auth, access_scope) && twitter_account
  end

  def update_from_omniauth(auth, access_scope)
    self.token        = auth.credentials.token   # can change, e.g. by changing access level...
    self.token_secret = auth.credentials.secret  #  ...or by revoking and reauthorizing access

    # Assign twitter authentcation scope for the provided credentials
    assign_access_scope(access_scope)

    # Assign user info
    assign_twitter_account_info(auth)

    # Save and return twitter account
    self.save! && self
  end

  # Fetches the mentions timeline from Twitter
  # while only fetching statuses that we have not already downloaded
  # Returns the persisted tweet records
  def fetch_mentions_timeline
    statuses = client.mentions_timeline(mentions_timeline_options)
    tweets = TweetMaker.many_from_twitter(statuses, project: project, twitter_account: self, state: :incoming)
    update_max_mentions_timeline_twitter_id(tweets.map(&:twitter_id).max)
    tweets
  # If there's an error, just skip execution
  rescue Twitter::Error
    false
  end

  # Fetches the user timeline from Twitter
  # while only fetching statuses that we have not already downloaded
  # Returns the persisted tweet records
  def fetch_user_timeline
    statuses = client.user_timeline(user_timeline_options)
    tweets = TweetMaker.many_from_twitter(statuses, project: project, twitter_account: self, state: :posted)
    update_max_user_timeline_twitter_id(tweets.map(&:twitter_id).max)
    tweets
  # If there's an error, just skip execution
  rescue Twitter::Error
    false
  end

  private

  def mentions_timeline_options
    options = { count: 200 } # Max is 200
    options[:since_id] = max_mentions_timeline_twitter_id if max_mentions_timeline_twitter_id.present?
    options
  end

  def user_timeline_options
    options = { count: 200 } # Max is 200
    options[:since_id] = max_user_timeline_twitter_id if max_user_timeline_twitter_id.present?
    options
  end

  def update_max_mentions_timeline_twitter_id(twitter_id)
    update_attributes(max_mentions_timeline_twitter_id: twitter_id) if twitter_id.to_i > max_mentions_timeline_twitter_id.to_i
  end

  def update_max_user_timeline_twitter_id(twitter_id)
    update_attributes(max_user_timeline_twitter_id: twitter_id) if twitter_id.to_i > max_user_timeline_twitter_id.to_i
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

  # Assign the access scope for the credentials
  def assign_access_scope(scope)
    ACCESS_SCOPES.include?(scope.to_s) or raise "'#{ scope }' is not a valid scope."
    self.access_scope = scope.to_s
  end

  ##
  # Default twitter account on project
  after_create :set_first_twitter_account_on_project_to_be_default_twitter_account

  def set_first_twitter_account_on_project_to_be_default_twitter_account
    project.set_default_twitter_account(self) unless project.has_default_twitter_account?
  end

  ##
  # Background jobs

  # Fetch conversation history from Twitter
  after_commit :import_timelines_async, on: :create

  def import_timelines_async
    TwitterAccountImportWorker.perform_async(self.id)
  end

end
