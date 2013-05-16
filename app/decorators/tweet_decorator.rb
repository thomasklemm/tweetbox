class TweetDecorator < Draper::Decorator
  delegate_all

  def link_to_status_on_twitter
    "https://twitter.com/#{ author.screen_name }/status/#{ twitter_id }"
  end

  def formatted_tweet
    "'#{ text }' \n Tweet by #{ author.name } (@#{ author.screen_name }) \n on #{ created_at.to_s(:long) }"
  end
end
