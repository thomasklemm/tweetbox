module ApplicationHelper
  # Hide certain content like user details
  # when response is set to be cached in public caches
  # (such as e.g. Rack Cache)
  def publicly_cached?
    !!(response.cache_control[:public])
  end

  # Set a DNS Prefetch tag
  def dns_prefetch(url)
    "<link rel='dns-prefetch' href='#{ url }'>".html_safe
  end

  # Returns a font-awesome icon tag
  def icon_tag(types, text=nil, fixed_width=false)
    klasses = [types].flatten.map { |type| "icon-#{ type }" }
    klasses << "icon-fixed-width" if fixed_width
    icon = content_tag :i, '', class: klasses.join(' ')
    icon + ' ' + text
  end

  def logo_header(title, subtitle=nil)
    content_tag :div, class: 'logo-header' do
      image_tag('tweetbox/logo.png') +
      content_tag(:span, title, class: 'title') +
      content_tag(:span, subtitle, class: 'subtitle')
    end
  end

  def timestamp_tag(time, opts={})
    opts[:class] ||= "timeago"
    content_tag(:abbr, time.to_s, opts.merge(:title => time.getutc.iso8601)) if time
  end

  def render_conversation?(tweet)
    tweet.incoming? || request.fullpath == project_tweet_path(@project, tweet)
  end

  def render_conversation_for_tweets(tweets)
    render partial: 'tweets/conversation_for_tweet', collection: tweets, as: :tweet
  end

  def public_status_view?
    params[:controller] && params[:controller] == 'public_statuses'
  end
end
