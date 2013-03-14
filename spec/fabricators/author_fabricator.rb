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

Fabricator(:author) do
  project
  twitter_id        { sequence(:twitter_id, 111111111111111111) }
  name              "author_name"
  screen_name       "author_screen_name"
  location          "author_location"
  description       "author_description"
  url               "author_url"
  verified          false
  followers_count   1
  friends_count     1
  profile_image_url "author_profile_image_url"
end
