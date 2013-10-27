module TweetEventHelper
  include ApplicationHelper
  attr_accessor :output_buffer

  def render_tweet_event(user_full_name, timestamp)
    content_tag :div, class: 'event started-replying', data: { user: user_full_name.parameterize } do
      icon_tag(:twitter) +
      "#{ user_full_name } started replying #{ timestamp_tag(timestamp) }.".html_safe
    end
  end
end
