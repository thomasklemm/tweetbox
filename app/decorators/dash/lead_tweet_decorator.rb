class LeadTweetDecorator < Draper::Decorator
  delegate_all

  def twitter_url
    "https://twitter.com/#{ lead.screen_name }/status/#{ twitter_id }"
  end

  def text
    h.link_twitter_text(model.text)
  end

  def source
    model.source
  end

  def created_at
    "#{ h.time_ago_in_words(model.created_at) } ago"
  end
end
