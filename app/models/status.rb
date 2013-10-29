class Status < ActiveRecord::Base
  belongs_to :project, inverse_of: :statuses
  belongs_to :user
  belongs_to :twitter_account
  has_one :tweet, inverse_of: :status

  before_validation :generate_token, if: :new_record?
  before_validation :generate_twitter_text, if: :new_record?

  validates :project,
            :text,
            :twitter_text,
            :token,
            :twitter_account,
            :user,
            presence: true
  validate :twitter_text_must_be_within_140_characters

  delegate :account, to: :project
  delegate :url_helpers, to: 'Rails.application.routes'

  # Checkbox to signal if a custom twitter text should be posted
  # Display only in case the text is longer than 140 characters,
  # otherwise this setting would be ignored
  attr_writer :use_twitter_text

  def use_twitter_text
    return false if @use_twitter_text.blank?
    return false if @use_twitter_text == '0'
    true
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

  ##
  # Length

  def text_length
    length_on_twitter(text)
  end

  def twitter_text_length
    length_on_twitter(twitter_text)
  end

  def length_on_twitter(text)
    text ||= ''
    Twitter::Validation.tweet_length(text)
  end

  ##
  # Publishing

  def published?
    !!twitter_id
  end

  # Publishes a status only once
  def publish!
    return true if published?
    publish_status!
  end

  def public_url
    # For correct URL length counting locally and on Twitter
    return "https://www.tweetbox.co/r/#{ token }" if Rails.env.development?
    url_helpers.public_status_url(token)
  end

  ##
  # Misc

  def to_param
    token
  end

  def mixpanel_id
    "status_#{ id }"
  end

  def mixpanel_hash
    {}
  end

  private

  ##
  # Token and validations

  def generate_token
    return true unless new_record?

    begin
      self[:token] = Tokenizer.random_token(6)
    end while Status.exists?(token: self[:token])
  end

  def twitter_text_must_be_within_140_characters
    unless length_on_twitter(twitter_text) <= 140
      errors.add(:twitter_text, "must be 140 characters or less")
    end
  end

  ##
  # Publishing

  def publish_status!
    status = twitter_account.client.update(twitter_text, publish_opts)

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

    self.save! and tweet.save!
  end

  # The posted status will be a reply on Twitter
  # only if :in_reply_to_status_id is present in publish_opts
  def publish_opts
    options = {}
    options[:in_reply_to_status_id] = in_reply_to_status_id if reply?
    options
  end

  def generate_twitter_text
    return true unless new_record?

    # Case A) Text is 140 characters or less
    # Don't allow a custom twitter_text if no URL will be added to access it
    # Don't display a custom field or the option to change the twitter_text
    # in case the text is less than or equal to 140 characters
    return self.twitter_text = text.strip if text_length <= 140

    # Case B) Text is above 140 characters
    # Display a checkbox and textarea for twitter_text

    # Case B.1) No custom twitter_text
    # Custom twitter text checkbox is unchecked
    # Don't set a custom twitter_text, even if one is sent from the form
    # Shorten the text + ellipsis with public url to 140 characters
    return self.twitter_text = shorten_text_and_public_url_to_140_characters unless use_twitter_text

    # Case B.2) Custom twitter_text
    # Custom Twitter text checkbox is checked
    if twitter_text.present?
      text_and_url = twitter_text.strip + " #{ public_url }"
      if length_on_twitter(text_and_url) <= 140
        # When a twitter_text has been given
        # Append the public url
        # Make sure in a validation that the result is less than or equal to
        # 140 characters, otherwise display a validation error in the form
        self.twitter_text = text_and_url
      else
        # Don't append URL if twitter text is too long as it will change
        # when the form is resubmitted
        # but add the error directly as the twitter text would be below 140 characters
        errors.add(:twitter_text, "must be 140 characters or less")
      end
    else
      # Don't append the url if no custom twitter_text has been entered
      # but the checkbox has been selected (displays "Twitter text
      # can't be blank" validation error)
    end
  end

  def shorten_text_and_public_url_to_140_characters
    # Strip all markdown and html, leave only text
    # as both markdown or html would look ugly on Twitter
    post = TweetPipeline.new(text).to_html
    post = Sanitize.clean(post)

    ellipsis = "... #{public_url}"

    # Shorten the text repeatedly for one character at a time
    # until it is no longer than 140 characters including the public url
    parts = [ post[0..200], ellipsis ]
    parts[0] = parts[0][0..-2].strip until length_on_twitter(parts.join) <= 140

    # Return the shortened text including the public url
    post = parts.join
  end
end
