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

  def ordered_tweets
    tweets.includes(:lead).order(created_at: :desc)
  end

  # Returns a lead record
  def self.from_twitter(user, opts={})
    return unless user

    lead = self.find_or_create_by(twitter_id: user.id)
    lead.send(:assign_fields, user)
    lead.save!

    # Free embeded status
    LeadTweet.from_twitter(user.status, lead) unless opts[:skip_status]

    lead
  rescue ActiveRecord::RecordNotUnique
    retry
  end

  # Returns a lead record
  # or nil if the user cannot be found on Twitter
  def self.find_or_fetch_by_screen_name(screen_name)
    lead = find_by(screen_name: screen_name)
    lead ||= fetch_by_screen_name(screen_name)
  end

  # Fetches the lead and the most recent 20 tweets
  def self.fetch_by_screen_name(screen_name)
    twitter_user = Twitter.user(screen_name)
    lead = self.from_twitter(twitter_user)
    lead.fetch_user_timeline(20)
    lead
  rescue Twitter::Error::NotFound
    nil
  end

  # Fetches and updates the current lead from Twitter
  def fetch_user
    user = Twitter.user(screen_name)
    Lead.from_twitter(user)
  end

  # Fetches the most recent
  # given number of tweets for the given user
  # Defaults to 200 tweets
  def fetch_user_timeline(n=200)
    tweets.destroy_all if n == 200
    statuses = Twitter.user_timeline(screen_name, count: n)
    LeadTweet.many_from_twitter(statuses)
  end

  def to_param
    screen_name
  end

  private

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
