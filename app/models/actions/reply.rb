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
  # TODO: Add posted_text text column
  validates :posted_text, presence: true

  before_validation :generate_posted_text_once

  def posted?
    posted_at.present?
  end

  def postable?
    valid? && !posted?
  end

  # Returns the posted tweet
  def post!
    return false unless postable?

    # status = twitter_account.client.update(posted_text, in_reply_to_status_id: tweet.twitter_id)
    # reply = project.create_tweet_from_twitter(status, twitter_account: twitter_account, state: :none)

    # Set timestamp
    touch(:posted_at)

    reply
  end

  private

  def generate_posted_text_once
    self.posted_text ||= generate_posted_text
  end

  def generate_posted_text
    length = Twitter::Validation.tweet_length(text)

    return text if length <= 140

    posted_text = text

    while Twitter::Validation.tweet_length(posted_text) > 124
      posted_text = posted_text[0..-2]
    end

    "#{ posted_text }... #{ link_to_reply }"
  end
end
