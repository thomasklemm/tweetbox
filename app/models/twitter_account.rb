# == Schema Information
#
# Table name: twitter_accounts
#
#  auth_scope            :string(255)
#  created_at            :datetime         not null
#  description           :string(255)
#  get_home              :boolean          default(TRUE)
#  get_mentions          :boolean          default(TRUE)
#  id                    :integer          not null, primary key
#  location              :string(255)
#  max_home_tweet_id     :integer
#  max_mentions_tweet_id :integer
#  name                  :string(255)
#  profile_image_url     :string(255)
#  project_id            :integer
#  screen_name           :string(255)
#  token                 :string(255)
#  token_secret          :string(255)
#  twitter_id            :integer
#  uid                   :string(255)
#  updated_at            :datetime         not null
#  url                   :string(255)
#
# Indexes
#
#  index_twitter_accounts_on_project_id          (project_id)
#  index_twitter_accounts_on_project_id_and_uid  (project_id,uid) UNIQUE
#  index_twitter_accounts_on_twitter_id          (twitter_id) UNIQUE
#

class TwitterAccount < ActiveRecord::Base
  # Project
  belongs_to :project
  validates :project, presence: true

  # Ensure uniqueness of twitter_account, can be associated with only one project
  # TODO: Add DB index to enforce uniqueness constraint
  validates :twitter_id, uniqueness: true

  # Credentials
  validates :uid, :token, :token_secret, presence: true

  # Auth scope
  validates :auth_scope, inclusion: { in: %w(read write messages) }

  # Returns a Twitter::Client instance for the twitter account
  def twitter_client
    Twitter::Client.new(
      oauth_token: token,
      oauth_token_secret: token_secret
    )
  end

  alias_method :client, :twitter_client

  # Create or update existing Twitter account
  def self.from_omniauth(project, auth, auth_scope)
    t = project.twitter_accounts.where(uid: auth.uid).first_or_initialize # uid cannot change

    # Credentials
    t.token        = auth.credentials.token   # can change, e.g. by changing access level...
    t.token_secret = auth.credentials.secret  #  ...or by revoking and reauthorizing access

    # User info
    user = auth.extra.raw_info
    t.twitter_id  = user.id
    t.name        = user.name
    t.screen_name = user.screen_name
    t.location    = user.location
    t.description = user.description
    t.url         = user.url
    t.profile_image_url = user.profile_image_url_https

    # Set twitter authentcation scope for the provided credentials
    t.map_auth_scope(auth_scope)

    # Save and return twitter account
    t.save! && t
  end

  # Set correct authentication scopes of Twitter account
  def map_auth_scope(auth_scope)
    case auth_scope
      when :read            then self.auth_scope = 'read'
      when :read_and_write  then self.auth_scope = 'write'
      when :direct_messages then self.auth_scope = 'messages'
      else
        raise "Please provide a valid Twitter auth scope."
      end
  end
end
