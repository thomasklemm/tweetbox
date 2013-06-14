class StatusDecorator < Draper::Decorator
  delegate_all

  def project_twitter_accounts
    project.twitter_accounts.select([:id, :screen_name, :name, :profile_image_url])
  end

  def project_twitter_accounts_in_json
    project_twitter_accounts.to_json
  end

  def selected_twitter_account
    twitter_account || project.default_twitter_account
  end

  def selected_twitter_account_position
    project_twitter_accounts.index(selected_twitter_account)
  end

  def initial_text
    reply? ? "#{ reply_to_tweet.author.at_screen_name } " : ""
  end

  def redirect_target_tweet
    reply_to_tweet || posted_tweet
  end
end
