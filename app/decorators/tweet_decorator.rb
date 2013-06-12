class TweetDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  decorates_association :conversation
  # decorates_association :events

  USER_INTENT_BASE_URL = "https://twitter.com/intent/user?screen_name="

  def author_intent_url
    "#{ USER_INTENT_BASE_URL }#{ author.screen_name }"
  end

  def author_profile
    "<img src='#{ author.profile_image_url }' class='avatar'></img>
    <span class='name'>#{ author.name }</span>
    <span class='screen-name'>#{ author.at_screen_name }</span>".html_safe
  end

  # Returns the autolinked tweet text
  def linked_text
    lt = Twitter::Autolink.auto_link_urls(text, url_target: :blank)

    options = {
      username_base_url: USER_INTENT_BASE_URL,
      username_include_symbol: true
    }
    lt = Twitter::Autolink.auto_link_usernames_or_lists(lt, options)
    lt.html_safe
  end

  def open_case_button(text, icon, opts={})
    link_to icon_tag(icon, text), open_case_project_tweet_path(project, self), opts.merge(method: :put)
  end

  def appreciate_tweet_button(text, icon, opts={})
    link_to icon_tag(icon, text), appreciate_project_tweet_path(project, self), opts.merge(method: :put)
  end

  def new_reply_button(text, icon, opts={})
    link_to icon_tag(icon, text), new_project_tweet_reply_path(project, self), opts
  end

  def resolve_case_button(text, icon, opts={})
    link_to icon_tag(icon, text), resolve_project_tweet_path(project, self), opts.merge(method: :put)
  end

  def retweet_button(text, icon, opts={})
    link_to icon_tag(icon, text), new_project_tweet_retweet_path(project, self), opts
  end

  def favorite_button(text, icon, opts={})
    link_to icon_tag(icon, text), new_project_tweet_favorite_path(project, self), opts
  end

  def status_on_twitter_url
    "https://twitter.com/#{ author.screen_name }/status/#{ twitter_id }"
  end

  def open_in_twitter_link(text, icon, opts={})
    link_to icon_tag(icon, text), status_on_twitter_url, opts.merge(target: :blank)
  end

  def copy_link(text, icon, opts={})
    link_to icon_tag(icon, text), 'javascript:;', class: 'copy-button',
      'data-clipboard-text' => "#{ status_on_twitter_url }"
  end

  def copy_text(text, icon, opts={})
    link_to icon_tag(icon, text), 'javascript:;', class: 'copy-button',
      'data-clipboard-text' => "#{ formatted_tweet_text }"
  end

  def formatted_tweet_text
    wrapped_text = word_wrap(text, line_width: 60)

    "'#{ wrapped_text }' \n
    Tweet by #{ author.name } (#{ author.at_screen_name }) \n
    at #{ created_at.to_s(:long) }"
  end
end
