class EventDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  def render
    send("render_#{ kind }")
  end

  private

  ##
  # Events

  def render_start_reply
    "#{ formatted_user_name } started replying. #{ formatted_timestamp }".html_safe
  end

  def render_post_reply
    "#{ formatted_user_name } replied to this tweet. See it below. #{ formatted_timestamp }".html_safe
  end

  def render_favorite
    "#{ formatted_user_name } favorited this tweet for @37signals. #{ formatted_timestamp }".html_safe
  end

  def render_unfavorite
    "#{ formatted_user_name } unfavorited this tweet for @37signals. #{ formatted_timestamp }".html_safe
  end

  def render_retweet
    "#{ formatted_user_name } retweeted this tweet to @37signals' followers. #{ formatted_timestamp }".html_safe
  end

  def render_appreciate
    "#{ formatted_user_name } appreciated this tweet. #{ formatted_timestamp }".html_safe
  end

  def render_resolve
    "#{ formatted_user_name } resolved this tweet. #{ formatted_timestamp }".html_safe
  end

  def render_post
    "#{ formatted_user_name } posted this tweet. #{ formatted_timestamp }".html_safe
  end

  def render_open_case
    "#{ formatted_user_name } started working on this tweet. #{ formatted_timestamp }".html_safe
  end

  ##
  # Shared

  def user_name
    user.name
  end

  def formatted_user_name
    "<span class='user-name'>#{ user_name }</span>".html_safe
  end

  def formatted_timestamp
    "<span class='timestamp'><i class='icon-time'></i> <abbr class='timeago' title='#{ created_at.iso8601 }'>#{ created_at.to_s(:long) }</abbr></span>".html_safe
  end
end
