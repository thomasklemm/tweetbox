class Status < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  belongs_to :twitter_account

  has_one :tweet

  before_validation :generate_token, if: :new_record?

  validates :project,
            :text,
            :token,
            :twitter_account,
            :user,
            presence: true

  def to_param
    token
  end

  ##
  # Is a Reply?

  def reply?
    !!in_reply_to_status_id
  end

  def previous_tweet
    return unless reply?
    @previous_tweet ||= TweetFinder.new(project, in_reply_to_status_id).find_or_fetch
  end


  # Is a Long Status?

  def long_status?
    length_on_twitter(text) > 140
  end

  def short_text
    @short_text ||= short_text!
  end

  def short_text_length
    length_on_twitter(short_text)
  end

  def text_length
    length_on_twitter(text)
  end

  ##
  # Publishing

  def published?
    !!twitter_id
  end

  def publish!
    return true if published?
    publish_status!
  end

  ##
  # Mixpanel

  def mixpanel_id
    "status_#{ id }"
  end

  include Rails.application.routes.url_helpers
  def mixpanel_hash
    {
      '$username'         => "#{ reply? ? 'Reply' : 'Status' } (#{ text_length } characters)",
      'Status Length'     => text_length,
      'Is Reply'          => reply?,
      'Is Long Status'    => long_status?,
      'Twitter URL'       => twitter_url,
      'Public Status URL' => public_status_url,
      'TA Screen Name'    => twitter_account.at_screen_name,
      'TA Name'           => twitter_account.name,
      'TA Twitter URL'    => twitter_account.twitter_url,
      'TA URL'            => dash_twitter_account_url(twitter_account),
      'Project Name'      => project.name,
      'Project URL'       => dash_project_url(project),
      'Account Name'      => account.name,
      'Account URL'       => dash_account_url(account)
    }
  end

  private

  # Generates a token without overriding the existing one
  def generate_token
    return true unless new_record?

    begin
      self[:token] = Tokenizer.random_token(6)
    end while Status.exists?(token: self[:token])
  end

  ##
  # Publishing

  def publish_status!
    status = twitter_account.client.update(short_text, publish_opts)

    # Assign the twitter id of the posted tweet
    # which also flags the status as published
    self.twitter_id = status.id

    # Save here already in case any of the later steps fail
    # in order to prevent a duplicate tweet on Twitter (would raise a Twitter::Error::Forbidden)
    self.save!

    # Create new posted tweet
    # and build conversation
    tweet = TweetMaker.from_twitter(status, project: project, twitter_account: twitter_account, state: :posted)

    # Link tweet and status together
    tweet.status = self

    # Create :post activity on new tweet...
    tweet.create_activity(:post, user)

    # ...and :post_reply activity on previous tweet
    previous_tweet.has_been_replied_to_by(user) if previous_tweet

    self.save! and tweet.save!
  end

  # The posted status will be a reply on Twitter
  # only if :in_reply_to_status_id is present in publish_opts
  def publish_opts
    options = {}
    options[:in_reply_to_status_id] = in_reply_to_status_id if reply?
    options
  end

  ##
  # Short text

  def short_text!
    return text if length_on_twitter(text) <= 140

    html = TweetPipeline.new(text).to_html
    text = Sanitize.clean(html)

    parts = [ text[0..200], "... #{ public_status_url }" ]
    parts[0] = parts[0][0..-2] until length_on_twitter(parts.join) <= 140
    parts.join
  end

  def length_on_twitter(text)
    Twitter::Validation.tweet_length(text)
  end

  def public_status_url
    Rails.application.routes.url_helpers.public_status_url(token)
  end
end
