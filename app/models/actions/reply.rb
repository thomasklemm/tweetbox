# == Schema Information
#
# Table name: replies
#
#  created_at         :datetime         not null
#  id                 :integer          not null, primary key
#  posted_at          :datetime
#  project_id         :integer          not null
#  text               :text             not null
#  tweet_id           :integer          not null
#  twitter_account_id :integer          not null
#  updated_at         :datetime         not null
#  user_id            :integer          not null
#
# Indexes
#
#  index_replies_on_project_id  (project_id)
#  index_replies_on_tweet_id    (tweet_id)
#  index_replies_on_user_id     (user_id)
#

class Reply < Action
  # Twitter account that performs the reply
  belongs_to :twitter_account
  validates :twitter_account, presence: true

  validates :text, presence: true

  def posted?
    posted_at.present?
  end

  def post!
    # ...
  end
end
