# Decorates Twitter::User records
class TwitterUserDecorator
  include UrlExpander

  attr_accessor :user

  def initialize(user)
    @user = user
  end

  delegate :screen_name,
           :name,
           :location,
           to: :user

  def lead
    @lead ||= Lead.find_by(twitter_id: twitter_id)
  end

  def twitter_id
    user.id
  end

  def profile_image_url
    user.try(:profile_image_url_https) || user.profile_image_url
  end

  def description
    @description ||= begin
      description_urls = user.attrs[:entities].try(:fetch, :description).try(:fetch, :urls, nil)
      description = description_urls ? expand_urls(user.description, description_urls) : user.description
      h.link_twitter_text(description)
    end
  end

  def url
    @url ||= begin
      url_urls = user.attrs[:entities].try(:fetch, :url, nil).try(:fetch, :urls, nil)
      url = url_urls ? expand_urls(user.url, url_urls) : user.url
      h.link_twitter_text(url)
    end
  end

  def lead_path
    "/dash/leads/#{ screen_name }"
  end

  def twitter_url
    "https://twitter.com/#{ screen_name }"
  end

  def at_screen_name
    "@#{ screen_name }"
  end

  def source
    @source ||= user.try(:status).try(:source).try(:html_safe)
  end

  def statuses_count
    h.number_with_delimiter(user.statuses_count)
  end

  def followers_count
    h.number_with_delimiter(user.followers_count)
  end

  def friends_count
    h.number_with_delimiter(user.friends_count)
  end

  # Twitter::User records are always unscored
  def score
    :unscored
  end

  private

  def h
    ApplicationController.helpers
  end
end
