# == Schema Information
#
# Table name: actions
#
#  created_at         :datetime         not null
#  id                 :integer          not null, primary key
#  posted_at          :datetime
#  project_id         :integer          not null
#  text               :text
#  tweet_id           :integer          not null
#  twitter_account_id :integer
#  type               :text             not null
#  updated_at         :datetime         not null
#  user_id            :integer          not null
#
# Indexes
#
#  index_actions_on_project_id  (project_id)
#  index_actions_on_tweet_id    (tweet_id)
#  index_actions_on_user_id     (user_id)
#

class Reply < Action
  validates :twitter_account, presence: true
  validates :text, presence: true

  def posted?
    posted_at.present?
  end

  def postable?
    valid? && !posted?
  end

  # Returns the posted tweet
  def post!
    return false unless postable?

    status = twitter_account.client.update(text, in_reply_to_status_id: tweet.twitter_id)
    reply = project.create_tweet_from_twitter(status, twitter_account: twitter_account, state: :none)

    # Set timestamp
    touch(:posted_at)

    reply
  end
end
