# == Schema Information
#
# Table name: statuses
#
#  code               :text             not null
#  created_at         :datetime         not null
#  id                 :integer          not null, primary key
#  posted_at          :datetime
#  posted_text        :text
#  project_id         :integer          not null
#  text               :text             not null
#  twitter_account_id :integer          not null
#  updated_at         :datetime         not null
#  user_id            :integer          not null
#
# Indexes
#
#  index_statuses_on_code        (code) UNIQUE
#  index_statuses_on_project_id  (project_id)
#

class Status < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  belongs_to :twitter_account

  before_validation :generate_code, if: :new_record?
  before_validation :generate_posted_text, if: :new_record?

  validates :project, :user, :twitter_account, presence: true
  validates :text, presence: true
  validates :code, presence: true, uniqueness: true

  def posted?
    !!posted_at
  end

  def posted_text
    self[:posted_text] || ''
  end

  def length
    Twitter::Validation.tweet_length(posted_text)
  end

  def valid_tweet?
    !invalid_tweet?
  end

  def public_url
    "https://tweetbox.com/statuses/#{ code }"
  end

  private

  def invalid_tweet?
    Twitter::Validation.tweet_invalid?(posted_text)
  end

  # Generates a unique random code
  def generate_code
    self.code ||= Random.new.code(8)
  end

  def generate_posted_text
    # Do not override posted text
    return if self[:posted_text].present?

    # Check if the text makes a good posted text
    self.posted_text = text
    return if valid_tweet?

    # If the tweet is too long, shorten it and append the public url
    # Limits the size of the initial tweet and iterations
    shortened_text = posted_text[0..210]
    text_parts = [shortened_text, "... #{ public_url }"]

    while length > 140
      shortened_text &&= shortened_text[0..-2]
      text_parts = [shortened_text, "... #{ public_url }"]
      self.posted_text = text_parts.join
    end

    posted_text
  end
end

# Reply
# belongs_to :in_reply_to_tweet


# delegate :url_helpers, to: 'Rails.application.routes'
# url_helpers.status_path(self)
