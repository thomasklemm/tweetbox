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

  def active_list_item(url_parts, exact=false)
    match = exact ? current_path == url_for(url_parts) : current_path.starts_with?(url_for(url_parts))
    content_tag :li, class: ('active' if match) do
      yield
    end
  end

  def render_conversation?(tweet)
    tweet.incoming? || current_path == project_tweet_path(@project, tweet)
  end

  ##
  # Caching

  def render_cached_conversation_for_tweets(tweets)
    render partial: 'tweets/conversation_for_tweet', collection: tweets, as: :tweet,
      cache: ->(tweet){digest('conversation_for', tweet, tweet.full_conversation) }
  end

  def digest(*items)
    items &&= items.
      flatten.
      map { |item| item.try(:cache_key) || item.try(:to_s) || item }

    cache_key = items.to_param
    cache_key.length < 64 ?  cache_key : Digest::MD5.hexdigest(cache_key)
  end

  def current_path
    request.fullpath
  end
end
