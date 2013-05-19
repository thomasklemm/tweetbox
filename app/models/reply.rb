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
#  index_replies_on_project_id_and_tweet_id  (project_id,tweet_id)
#

class Reply < ActiveRecord::Base
  belongs_to :project
  validates :project, presence: true

  # Reply to a tweet
  belongs_to :tweet, counter_cache: true
  validates :tweet, presence: true

  # Twitter account to post reply with
  belongs_to :twitter_account
  validates :twitter_account, presence: true

  # User who posts reply
  belongs_to :user
  validates :user, presence: true

  # Reply text
  validates :text, presence: true

  before_validation :assign_project_id_from_tweet

  def project=(ignored)
    raise NotImplementedError, "Use Reply#tweet= instead"
  end

  # def post!
  #   client = twitter_account.client
  #   if client.update(text) # FIXME: reply to tweet
  #     self.posted_at = Time.now
  #     self.save!
  #   else
  #     # ...
  #   end
  # end

  private

  def assign_project_id_from_tweet
    self.project_id = tweet.try(:project_id)
  end
end
