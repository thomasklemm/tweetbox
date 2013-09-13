class TweetDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  # REVIEW: Maybe create author dec
  # for right now: author intent url
  # decorates_association :author

  # Returns the autolinked status or tweet text
  def text
    # TODO: Display status.try(:text)
    SimpleTweetPipeline.new(model.text).to_html
  end

  ##
  # Sorted associations
  # (Should be done by database, but seems like eager loading skips order)

  def previous_tweets
    model.previous_tweets.sort_by(&:created_at)
  end

  def future_tweets
    model.future_tweets.sort_by(&:created_at)
  end

  ##
  # URLs

  USER_INTENT_URL_BASE  = "https://twitter.com/intent/user?screen_name="
  REPLY_INTENT_URL_BASE = "https://twitter.com/intent/tweet?in_reply_to="

  # REVIEW: Maybe transfer to an author decorator
  def author_intent_url
    "#{ USER_INTENT_URL_BASE }#{ author.screen_name }"
  end

  def reply_intent_url
    "#{ REPLY_INTENT_URL_BASE }#{ twitter_id }"
  end

  def twitter_url
    "https://twitter.com/#{ author.screen_name }/status/#{ twitter_id }"
  end

  ##
  # Old actions

  def resolve_button(text, icon, opts={})
    link_to icon_tag(icon, text), resolve_project_tweet_path(project, self), opts.merge(method: :post)
  end

  def reply_button(text, icon, opts={})
    link_to icon_tag(icon, text), new_project_tweet_reply_path(project, self), opts
  end

  def activate_button(text, icon, opts={})
    link_to icon_tag(icon, text), activate_project_tweet_path(project, self), opts.merge(method: :post)
  end

  def retweet_button(text, icon, opts={})
    link_to icon_tag(icon, text), new_project_tweet_retweet_path(project, self), opts
  end

  def favorite_button(text, icon, opts={})
    link_to icon_tag(icon, text), new_project_tweet_favorite_path(project, self), opts
  end

  def open_in_twitter_link(text, icon, opts={})
    link_to icon_tag(icon, text), twitter_url, opts.merge(target: :blank)
  end

  def copy_link(text, icon, opts={})
    link_to icon_tag(icon, text), 'javascript:;', class: 'copy-button',
      'data-clipboard-text' => "#{ twitter_url }"
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

  def to_s
    "TweetDecorator: #{ model.to_s }"
  end
end
