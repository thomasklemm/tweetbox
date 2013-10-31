class SalesTweet < ActiveRecord::Base
  validates :text, :twitter_text, presence: true

  def render_text_for(username)
    Liquid::Template.parse(text).render('username' => username)
  end

  def render_twitter_text_for(username)
    Liquid::Template.parse(twitter_text).render('username' => username)
  end
end
