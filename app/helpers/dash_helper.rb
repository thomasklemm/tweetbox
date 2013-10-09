module DashHelper
  def link_twitter_text(text)
    user_options = { username_include_symbol: true }
    text = Twitter::Autolink.auto_link_urls(text, url_target: :blank)
    Twitter::Autolink.auto_link_usernames_or_lists(text, user_options)
  end

  def score_title(score)
    case score.to_s
    when 'high'      then 'High Scoring Leads'
    when 'medium'    then 'Medium Scoring Leads'
    when 'secondary' then 'Secondary Accounts'
    when 'unscored'  then 'Unscored Leads'
    end
  end

  def score_icon_tag(score)
    case score.to_s
    when 'high'      then icon_tag('star', 'High Score')
    when 'medium'    then icon_tag('star-half-full')
    when 'secondary' then icon_tag('star-empty')
    else                  icon_tag('ok')
    end
  end

  def stat(key, value)
    content_tag :span, class: 'stat' do
      concat content_tag(:span, key, class: 'key')
      concat content_tag(:span, value, class: 'value')
    end
  end

  def extended_view?(lead)
    return unless request.fullpath == dash_lead_path(lead)

    if params[:action] == 'update'
      request.referer == dash_lead_url(lead)
    else
      true
    end
  end
end
