# == Schema Information
#
# Table name: favorites
#
#  created_at         :datetime         not null
#  id                 :integer          not null, primary key
#  posted_at          :datetime
#  project_id         :integer          not null
#  tweet_id           :integer          not null
#  twitter_account_id :integer
#  undone_at          :datetime
#  updated_at         :datetime         not null
#  user_id            :integer          not null
#
# Indexes
#
#  index_favorites_on_project_id  (project_id)
#  index_favorites_on_tweet_id    (tweet_id)
#  index_favorites_on_user_id     (user_id)
#

class Favorite < Action
  def posted?
    return false if posted_at.blank?
    return true if posted_at.present? && undone_at.blank?
    posted_at > undone_at # Reposted if posted_at greater than undone_at
  end

  def post!
    # ...
  end

  def undo!
    # ...
  end
end
