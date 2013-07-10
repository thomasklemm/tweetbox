class Author < ActiveRecord::Base
  # include Twitter::Urls

  belongs_to :project
  validates :project, presence: true

  has_many :tweets

  # Ensure that only one author record is created for each project
  validates_uniqueness_of :twitter_id, scope: :project_id

  def at_screen_name
    "@#{ screen_name }"
  end

  # Assigns the author's fields from a Twitter status object
  # Persists the changes to the database by saving the record
  # Returns the author record
  def update_fields_from_status(status)
    assign_fields_from_status(status)
    save && self
  end

  private

  # Assigns the author's fields from a Twitter status object
  # Returns the author record without saving it and persisting
  # the changes to the database
  # TODO: Replace t.co entities on description and url
  def assign_fields_from_status(status)
    user = status.user
    self.twitter_id        = user.id
    self.name              = user.name
    self.screen_name       = user.screen_name
    self.location          = user.location
    self.description       = user.description # Twitter::Urls.expand(user.description, user.urls)
    self.url               = user.url # Twitter::Urls.expand(user.url, user.urls)
    self.verified          = user.verified
    self.created_at        = user.created_at
    self.followers_count   = user.followers_count
    self.friends_count     = user.friends_count
    self.statuses_count    = user.statuses_count
    self.profile_image_url = user.profile_image_url_https
    self
  end
end
