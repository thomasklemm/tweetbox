module DashHelper
  def link_twitter_text(text)
    user_options = { username_include_symbol: true }
    text = Twitter::Autolink.auto_link_urls(text, url_target: :blank)
    Twitter::Autolink.auto_link_usernames_or_lists(text, user_options)
  end

  # Returns a font-awesome icon tag
  def icon_tag(type, text=nil)
    "<i class='icon-#{ type.to_s }'></i> #{ text }".html_safe
  end

  def score_icon_tag(score)
    case score.to_s
    when 'high'      then icon_tag('star')
    when 'medium'    then icon_tag('star-half-full')
    when 'secondary' then icon_tag('star-empty')
    else                  icon_tag('ok')
    end
  end

  # Highlights the currently active navigation item with a special class
  def active_list_item_link_to(*args)
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

  def logo_header(text)
    content_tag :h3, class: 'logo-header' do
      concat image_tag 'Tweetbox-Logo.png'
      concat text
    end

    # "<h3>#{ image_tag 'Tweetbox-Logo.png', width: 42, style: 'margin-right: 8px' }#{ text }</h3>".html_safe
  end

  def stat(key, value)
    content_tag :span, class: 'stat' do
      concat content_tag(:span, key, class: 'key')
      concat content_tag(:span, value, class: 'value')
    end
  end

  def extended_view?(lead)
    return unless current_path == dash_lead_path(lead)

    if params[:action] == 'update'
      request.referer == dash_lead_url(lead)
    else
      true
    end
  end

  private

  def current_path
    request.fullpath
  end
end
