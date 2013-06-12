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
    "#{ user_name } started replying #{ timestamp }."
  end

  def render_post_reply
    "#{ user_name } replied #{ timestamp }: THIS IS THE REPLY TEXT."
  end

  def render_favorite
    "#{ user_name } favorited this tweet for @37signals #{ timestamp }."
  end

  def render_unfavorite
    "#{ user_name } unfavorited this tweet for @37signals #{ timestamp }."
  end

  def render_retweet
    "#{ user_name } retweeted this tweet to @37signals' followers #{ timestamp }."
  end

  def render_appreciate
    "#{ user_name } appreciated this tweet #{ timestamp }."
  end

  def render_resolve
    "#{ user_name } resolved this tweet #{ timestamp }."
  end

  def render_post
    "#{ user_name } posted this tweet #{ timestamp }."
  end

  def render_open_case
    "#{ user_name } started working on this tweet #{ timestamp }."
  end

  ##
  # Shared

  def user_name
    user.name
  end

  def timestamp
    "a few seconds ago"
  end
end
