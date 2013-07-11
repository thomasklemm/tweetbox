class Author < ActiveRecord::Base
  include UrlExpander

  belongs_to :project
  validates :project, presence: true

  has_many :tweets

  # Ensure that only one author record is created for each project
  validates_uniqueness_of :twitter_id, scope: :project_id

  def at_screen_name
    "@#{ screen_name }"
  end

  def self.from_twitter(user, opts={})
    project = opts.fetch(:project) { raise 'Requires a :project' }

    author = project.authors.where(twitter_id: user.id).first_or_initialize
    author.assign_fields(user)

    author.save! and author
  rescue ActiveRecord::RecordNotUnique
    retry
  end

  def assign_fields(user)
    self.screen_name = user.screen_name
    self.name = user.name
    description_urls = user.attrs[:entities].try(:fetch, :description).try(:fetch, :urls, nil)
    self.description = expand_urls(user.description, description_urls)
    self.location = user.location
    self.profile_image_url = user.profile_image_url_https
    url_urls = user.attrs[:entities].try(:fetch, :url, nil).try(:fetch, :urls, nil)
    self.url = url_urls.present? ? expand_urls(user.url, url_urls) : user.url
    self.followers_count = user.followers_count
    self.statuses_count = user.statuses_count
    self.friends_count = user.friends_count
    self.joined_twitter_at = user.created_at
    self.lang = user.lang
    self.time_zone = user.time_zone
    self.verified = user.verified
    self
  end
end
