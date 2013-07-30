class LeadTweet < ActiveRecord::Base
  include UrlExpander

  belongs_to :lead

  validates :twitter_id, presence: true

  # Returns the persisted tweet record given a single Twitter::Tweet instance
  # or an array of persisted tweet records given an array of Twitter::Tweet instances
  def self.from_twitter(status, lead=nil)
    case status
    when Array
      status.map { |s| from_twitter(s, lead) }
    else
      tweet = self.find_or_create_by(twitter_id: status.id)
      tweet.send(:assign_fields, status)
      tweet.lead = lead || Lead.from_twitter(status.user, skip_status: true)
      tweet.save! and tweet
    end
  rescue ActiveRecord::RecordNotUnique
    retry
  end

  private

  # Assigns fields from a Twitter::Tweet object
  def assign_fields(status)
    self.text = expand_urls(status.text, status.urls)
    self.in_reply_to_user_id = status.in_reply_to_user_id
    self.in_reply_to_status_id = status.in_reply_to_status_id
    self.source = status.source
    self.lang = status.lang
    self.retweet_count = status.retweet_count
    self.favorite_count = status.favorite_count
    self.created_at = status.created_at
    self
  end
end
