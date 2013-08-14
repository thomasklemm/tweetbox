class StatusDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  REPLY_INTENT_URL_BASE = "https://twitter.com/intent/tweet?in_reply_to="

  def text
    TweetPipeline.new(model.text).to_html
  end

  def short_text
    TweetPipeline.new(model.short_text).to_html
  end

  def reply_intent_url
    "#{ REPLY_INTENT_URL_BASE }#{ twitter_id }"
  end

  def twitter_url
    "https://twitter.com/#{ twitter_account.screen_name }/status/#{ twitter_id }" if published?
  end

  ##
  # Initial reply to user text

  def in_reply_to_user
    previous_tweet.try(:author).try(:screen_name) || params[:in_reply_to_user]
  end

  def initial_reply_to_user_text
    in_reply_to_user ? "@#{ in_reply_to_user } " : ""
  end

  ##
  # Angular form stuff

  def project_twitter_accounts
    project.twitter_accounts
  end

  def project_twitter_accounts_in_json
    project_twitter_accounts.map(&:serialized_hash).to_json
  end

  def selected_twitter_account
    twitter_account || previous_tweet.try(:twitter_account) || project.default_twitter_account || project.twitter_accounts.sample
  end

  def selected_twitter_account_id
    selected_twitter_account.try(:id)
  end

  def selected_twitter_account_position
    project_twitter_accounts.index(selected_twitter_account)
  end

  ##
  # Response time

  def response_time_in_words
    distance_of_time_in_words(previous_tweet.try(:created_at), tweet.try(:created_at) || Time.current, include_seconds: true)
  end
end
