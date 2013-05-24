class NewStatus
  include ActiveAttr::BasicModel
  include Virtus

  attribute :text, String
  attribute :posted_text, String
  validates :text, :posted_text, presence: true

  attribute :project, Project
  attribute :user, User
  validates :project, :user, presence: true

  attribute :twitter_account, TwitterAccount
  attribute :code, String
  validates :twitter_account, :code, presence: true

  attribute :in_reply_to_status_id, Integer
  attribute :in_reply_to_user, String
  attribute :in_reply_to_tweet, Tweet

  def save
    generate_code
    generate_posted_text

    if valid? && valid_tweet?
      post!
      true
    else
      false
    end
  end

  def text=(new_text)
    super
    self.posted_text = new_text
  end

  private

  def tweet_length(text)
    Twitter::Validation.tweet_length(text)
  end

  def public_url
    raise "Code must be generated before calling public_url" unless code
    "http://birdview.dev/read-more/#{ code }"
  end

  def ellipsis_and_public_url
    "...\n#{ public_url }"
  end

  def generate_posted_text
    return self.posted_text = text if tweet_length(text) <= 140

    virtual_text = text.slice(0, 225)
    parts = [virtual_text, ellipsis_and_public_url]

    while tweet_length(parts.join) > 140
      parts = [virtual_text.slice(0, -2), ellipsis_and_public_url]
    end

    self.posted_text = parts.join
  end

  def valid_tweet?
    !Twitter::Validation.tweet_invalid?(@posted_text)
  end



  def post!

  end
end
