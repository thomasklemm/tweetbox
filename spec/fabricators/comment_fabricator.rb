# == Schema Information
#
# Table name: comments
#
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  project_id :integer          not null
#  text       :text             not null
#  tweet_id   :integer          not null
#  updated_at :datetime         not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_comments_on_project_id_and_tweet_id  (project_id,tweet_id)
#

Fabricator(:comment) do
  project nil
  tweet   nil
  user    nil
  text    "MyText"
end
