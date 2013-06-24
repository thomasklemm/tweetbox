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

  # Only destroy a twitter account if no search is associated
  has_many :searches, dependent: :restrict

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

  def client
    Twitter::Client.new(
      oauth_token: token,
      oauth_token_secret: token_secret
    )
  end

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

  def update_max_mentions_timeline_twitter_id(twitter_id)
    update_attributes(max_mentions_timeline_twitter_id: twitter_id) if twitter_id.to_i > max_mentions_timeline_twitter_id.to_i
  end

  def update_max_user_timeline_twitter_id(twitter_id)
    update_attributes(max_user_timeline_twitter_id: twitter_id) if twitter_id.to_i > max_user_timeline_twitter_id.to_i
  end

  def can_be_removed?
    searches.empty? && !is_project_default?
  end

  def serialized_hash
    { id: id, screen_name: screen_name, name: name, profile_image_url: profile_image_url, at_screen_name: at_screen_name }
  end

  private

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

  def project_default?
    project.default_twitter_account_id == id
  end

  after_commit :ensure_project_default_is_set

  def ensure_project_default_is_set
    project.set_default_twitter_account(self) unless project.default_twitter_account.present?
  end
end
