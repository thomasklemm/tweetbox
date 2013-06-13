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
  def icon_tag(type, text=nil)
    "<i class='icon-#{ type.to_s }'></i> #{ text }".html_safe
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

  private

  def current_path
    request.fullpath
  end
end
