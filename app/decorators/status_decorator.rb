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
end
