module ApplicationHelper
  include Twitter::Autolink

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

  def active_link_to(*args)
    link = link_to(*args)
    path_args = args.second or raise StandardError, 'Expected URL to be second argument.'

    if current_path.start_with?(url_for(path_args))
      "<li class='active'>#{ link }</li>".html_safe
    else
      "<li>#{ link }</li>".html_safe
    end
  end

  def current_path
    request.fullpath
  end

  def icon_tag(type, text=nil)
    "<i class='icon-#{ type.to_s }'></i> #{ text }".html_safe
  end
end
