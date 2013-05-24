class TweetDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  decorates_association :conversation

  # TODO: Add boolean flag or timestamp
  def retweeted?
    false
  end

  def favorited?
    false
  end

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

  def open_button(text)
    link_to icon_tag(:plus, text),
      transition_project_tweet_path(project, self, to: :open), method: :put
  end

  def close_button(text)
    link_to icon_tag(:ok, text),
      transition_project_tweet_path(project, self, to: :closed), method: :put
  end

  def reply_button(text)
    link_to icon_tag(:reply, text),
      new_project_tweet_reply_path(project, self)
  end

  def comment_button(text)
    link_to icon_tag(:'comment-alt', text),
      new_project_tweet_comment_path(project, self)
  end

  def retweet_button(text)
    link_to icon_tag(:retweet, text),
      new_project_tweet_retweet_path(project, self)
  end

  def favorite_button(text)
    link_to icon_tag(:star, text),
      new_project_tweet_favorite_path(project, self, type: :favorite)
  end

  def unfavorite_button(text)
    link_to icon_tag(:'star-empty', text),
      new_project_tweet_favorite_path(project, self, type: :unfavorite)
  end

  def open_in_twitter_button(text)
    link_to icon_tag(:twitter, text), status_in_twitter_url
  end

  def status_in_twitter_url
    "https://twitter.com/#{ author.screen_name }/status/#{ twitter_id }"
  end

  def copy_tweet_button(text)
    link_to icon_tag(:copy, text), 'javascript:;',
      class: 'copy-button', 'data-clipboard-text' => "#{ formatted_tweet_text }"
  end

  def formatted_tweet_text
    wrapped_text = word_wrap(text, line_width: 60)

    "'#{ wrapped_text }' \n
    Tweet by #{ author.name } (#{ author.at_screen_name }) \n
    at #{ created_at.to_s(:long) }"
  end
end
