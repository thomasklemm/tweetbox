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

  # Highlights the currently active navigation item with a special class
  def active_link_to(*args)
    link = link_to(*args)
    path_args = args.second or raise StandardError, 'Expected URL to be second argument.'
    exact = args.third.try(:fetch, :exact, false)

    match = if exact
      current_path == url_for(path_args)
    else
      current_path.start_with?(url_for(path_args))
    end

    content_tag(:li, link, class: "#{ 'active' if match }")
  end

  def incoming_tweets_path?
    current_path == incoming_project_tweets_path(@project)
  end

  def resolved_tweets_path?
    current_path == resolved_project_tweets_path(@project)
  end

  def posted_tweets_path?
    current_path == posted_project_tweets_path(@project)
  end

  def show_tweet?(tweet)
    current_path == project_tweet_path(@project, tweet)
  end

  def logo_header(text)
    content_tag :h3, class: 'logo-header' do
      concat image_tag 'tweetbox/logo.png'
      concat text
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

  def active_li_link_to(*args, &block)

    link = link_to(*args)
  end

  def active_path?(path, fuzzy)

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

  private

  def current_path
    request.fullpath
  end
end
