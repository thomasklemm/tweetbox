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
#  project_id        :integer          not null
#  screen_name       :text
#  statuses_count    :integer          default(0)
#  twitter_id        :integer          not null
#  updated_at        :datetime         not null
#  url               :text
#  verified          :boolean          default(FALSE)
#
# Indexes
#
#  index_authors_on_project_id                 (project_id)
#  index_authors_on_project_id_and_twitter_id  (project_id,twitter_id) UNIQUE
#

Fabricator(:author) do
  project
  twitter_id        { sequence(:twitter_id, 111111111111111111) }
  screen_name       "author_screen_name"
end
