# == Schema Information
#
# Table name: twitter_accounts
#
#  access_scope                            :text
#  created_at                              :datetime         not null
#  description                             :text
#  id                                      :integer          not null, primary key
#  location                                :text
#  max_direct_messages_received_twitter_id :integer
#  max_direct_messages_sent_twitter_id     :integer
#  max_mentions_timeline_twitter_id        :integer
#  max_user_timeline_twitter_id            :integer
#  name                                    :text
#  profile_image_url                       :text
#  project_id                              :integer          not null
#  screen_name                             :text
#  token                                   :text             not null
#  token_secret                            :text             not null
#  twitter_id                              :integer          not null
#  uid                                     :text             not null
#  updated_at                              :datetime         not null
#  url                                     :text
#
# Indexes
#
#  index_twitter_accounts_on_project_id                   (project_id)
#  index_twitter_accounts_on_project_id_and_access_scope  (project_id,access_scope)
#  index_twitter_accounts_on_project_id_and_twitter_id    (project_id,twitter_id)
#  index_twitter_accounts_on_twitter_id                   (twitter_id) UNIQUE
#

class TwitterAccount < ActiveRecord::Base
  extend Enumerize

  ACCESS_SCOPES = %w(read write)
  QUERIES = %w(mentions_timeline user_time direct_messages_received direct_messages_sent)

  belongs_to :project
  validates :project, presence: true

  # Each twitter account can be associated with only one project
  validates :twitter_id, presence: true, uniqueness: true

  # Credentials used for authenticating with Twitter
  validates :uid, :token, :token_secret, presence: true

  # Access scope
  enumerize :access_scope, in: ACCESS_SCOPES
  # #access_scope.read?
  # #access_scope.write?
  # TwitterAccount.with_access_scope(:read)
  # TwitterAccount.with_access_scope(:read, :write)

  # Only destroy a twitter account if no search is associated
  has_many :searches, dependent: :restrict

  # Callbacks
  before_save :set_first_authorized_twitter_account_to_be_project_default

  def at_screen_name
    "@#{ screen_name }"
  end

  def destroyable?
    project.default_twitter_account_id != id && searches.empty?
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
  def self.from_omniauth(project, auth, access_scope)
    twitter_account = project.twitter_accounts.where(uid: auth.uid).first_or_initialize # uid cannot change
    twitter_account.update_from_omniauth(auth, access_scope) && twitter_account
  end

  def update_from_omniauth(auth, access_scope)
    # Store credentials
    self.token        = auth.credentials.token   # can change, e.g. by changing access level...
    self.token_secret = auth.credentials.secret  #  ...or by revoking and reauthorizing access

    # Assign twitter authentcation scope for the provided credentials
    assign_access_scope(access_scope)

    # Assign user info
    assign_twitter_account_info(auth)

    # Save and return twitter account
    self.save! && self
  end

  def update_stats!(type, new_max_twitter_id)
    type &&= type.to_s
    QUERIES.include?(type) or raise StandardError, "Please provide a valid type: '#{ type }' could not be recognized."
    write_attribute("max_#{type}_twitter_id", new_max_twitter_id)
    self.save!
  end

  # Set the current twitter account to be the project's default twitter account
  def default!
    project.default_twitter_account = self
    project.save!
  end

  private

  def set_first_authorized_twitter_account_to_be_project_default
    default! unless project.default_twitter_account.present?
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
    ACCESS_SCOPES.include?(scope.to_s) or
      raise StandardError, "TwitterAccount#assign_access_scope: '#{ scope }' is not a valid scope."

    self.access_scope = scope.to_s
  end
end
