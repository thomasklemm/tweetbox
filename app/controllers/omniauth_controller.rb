class OmniauthController < ProjectController
  # Handle the omniauth callback from Twitter
  def twitter
    auth = request.env['omniauth.auth']
    auth_scope = user_session.delete(:twitter_auth_scope)
    user_session.delete(:project_id)

    # Create or update twitter account
    twitter_account = TwitterAccount.from_omniauth(@project, auth, auth_scope)

    flash.notice = "Twitter account @#{ twitter_account.screen_name } has been successfully authorized."
    redirect_to project_twitter_accounts_path(@project)
  end

  # Handle failed omniauth authorization requests
  def failure
    user_session.delete(:twitter_auth_scope)
    user_session.delete(:project_id)

    flash.alert = "Failed to authorize Twitter account."
    redirect_to project_twitter_accounts_path(@project)
  end
end
