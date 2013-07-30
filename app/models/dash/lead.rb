class Lead < ActiveRecord::Base
  extend Enumerize
  include UrlExpander

  has_many :tweets, dependent: :destroy, class_name: 'LeadTweet'

  validates :twitter_id,
            :screen_name,
            presence: true

  scope :by_statuses_count, -> { order(statuses_count: :desc) }
  scope :by_joined_twitter_at, -> { order(joined_twitter_at: :asc) }

  # Score
  enumerize :score,
    in: [:high, :medium, :secondary, :unscored],
    default: :unscored,
    predicates: { prefix: true },
    scope: :having_score

  # Pagination
  paginates_per 30

  # Tweets with eager loaded self
  def ordered_tweets
    tweets.includes(:lead).order(created_at: :desc)
  end


  ##
  # Class methods

  # Returns a lead record given a screen_name or twitter_id
  # or nil if the user cannot be found on Twitter
  def self.find_or_fetch_by(opts={})
    twitter_id = params[:twitter_id]
    screen_name = params[:screen_name]

    raise "A screen_name or twitter_id option is required" unless screen_name || twitter_id
    raise "Exclusive options screen_name and twitter_id can not be present at once" if screen_name && twitter_id

    lead = find_by(twitter_id: twitter_id) if twitter_id
    lead = find_by(screen_name: screen_name) if screen_name

    lead ||= fetch(screen_name || twitter_id)
  end

  # Fetches the lead
  # Fetches the most recent 50 tweets in the background
  # Returns the persisted lead
  def self.fetch(screen_name_or_twitter_id)
    twitter_user = twitter_client.user(screen_name_or_twitter_id)
    lead = self.from_twitter(twitter_user)

    # Fetch most recent tweets in the background
    lead.delay.fetch_user_timeline(50)

    lead
  rescue Twitter::Error::NotFound
    nil
  end

  # Returns the persisted lead record given a single Twitter::User instance
  # or an array of the persisted lead records given an array of Twitter::User instances
  def self.from_twitter(user, opts={})
    case user
    when Array
      user.map { |u| from_twitter(u, opts) }
    else
      lead = self.find_or_create_by(twitter_id: user.id)
      lead.send(:assign_fields, user)
      lead.save!

      # Free embeded status
      LeadTweet.from_twitter(user.status, lead) unless opts[:skip_status]

      lead
    end
  rescue ActiveRecord::RecordNotUnique
    retry
  end


  ##
  # Instance methods

  # Fetches and updates the current lead from Twitter
  def fetch_user
    twitter_user = twitter_client.user(screen_name)
    Lead.from_twitter(twitter_user)
  end

  # Fetches the most recent
  # given number of tweets for the given user
  # Defaults to 100 tweets
  def fetch_user_timeline(n=100)
    statuses = twitter_client.user_timeline(screen_name, count: n)
    LeadTweet.from_twitter(statuses)
  end

  def to_param
    screen_name
  end

  private

  ##
  # Class methods

  # Returns a random twitter client
  def self.twitter_client
    RandomTwitterClient.new
  end

  ##
  # Instance methods

  # Returns a random twitter client
  def twitter_client
    RandomTwitterClient.new
  end

  # Assigns fields from a Twitter::User object
  def assign_fields(user)
    self.screen_name = user.screen_name
    self.name = user.name
    description_urls = user.attrs[:entities].try(:fetch, :description).try(:fetch, :urls, nil)
    self.description = description_urls ? expand_urls(user.description, description_urls) : user.description
    self.location = user.location
    self.profile_image_url = user.profile_image_url_https
    url_urls = user.attrs[:entities].try(:fetch, :url, nil).try(:fetch, :urls, nil)
    self.url = url_urls ? expand_urls(user.url, url_urls) : user.url
    self.followers_count = user.followers_count
    self.statuses_count = user.statuses_count
    self.friends_count = user.friends_count
    self.joined_twitter_at = user.created_at
    self.lang = user.lang
    self.time_zone = user.time_zone
    self.verified = user.verified
    self.following = user.following
    self
  end
end
