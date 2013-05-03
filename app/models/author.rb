# == Schema Information
#
# Table name: authors
#
#  created_at        :datetime         not null
#  description       :text
#  followers_count   :integer          default(0)
#  friends_count     :integer          default(0)
#  id                :integer          not null, primary key
#  location          :text
#  name              :text
#  profile_image_url :text
#  project_id        :integer
#  screen_name       :text
#  twitter_id        :integer
#  updated_at        :datetime         not null
#  url               :text
#  verified          :boolean          default(FALSE)
#
# Indexes
#
#  index_authors_on_project_id                 (project_id)
#  index_authors_on_project_id_and_twitter_id  (project_id,twitter_id) UNIQUE
#  index_authors_on_twitter_id                 (twitter_id)
#

class Author < ActiveRecord::Base
  belongs_to :project
  validates :project, presence: true

  has_many :tweets

  # Ensure that only one author record is created for each project
  validates_uniqueness_of :twitter_id, scope: :project_id

  # Assigns the author's fields from a Twitter status object
  # Persists the changes to the database by saving the record
  # Returns the author record
  def update_fields_from_status(status)
    self.assign_fields_from_status(status)
    self.save && self
  end

  private

  # Assigns the author's fields from a Twitter status object
  # Returns the author record without saving it and persisting
  # the changes to the database
  def assign_fields_from_status(status)
    self.twitter_id  = status.user.id
    self.name        = status.user.name
    self.screen_name = status.user.screen_name
    self.location    = status.user.location
    self.description = status.user.description
    self.url         = status.user.url
    self.verified    = status.user.verified
    self.created_at  = status.user.created_at
    self.followers_count   = status.user.followers_count
    self.friends_count     = status.user.friends_count
    self.profile_image_url = status.user.profile_image_url_https
    self
  end
end
