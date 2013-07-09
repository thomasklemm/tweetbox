class OmniauthController < ProjectController
  # Handle the omniauth callback from Twitter
  def twitter
    auth = request.env['omniauth.auth']
    access_scope = user_session.delete(:access_scope)
    user_session.delete(:project_id)

    # Create or update twitter account
    twitter_account = TwitterAccount.from_omniauth(@project, auth, access_scope)

    redirect_to project_twitter_accounts_path(@project),
      notice: "Your Twitter account #{ twitter_account.at_screen_name } has been connected."
  end

  # Handle failed omniauth authorization requests
  def failure
    user_session.delete(:access_scope)
    user_session.delete(:project_id)

    redirect_to project_twitter_accounts_path(@project),
      alert: "Your Twitter account could not be connected."
  end
end
