class OmniauthController < ProjectController
  # Handle the omniauth callback from Twitter
  def twitter
    auth = request.env['omniauth.auth']
    # Create or update twitter account
    twitter_account = TwitterAccount.from_omniauth(@project, auth, @access_scope)

    event_name = twitter_account.is_new_record ? 'Twitter Account Connect' : 'Twitter Account Reconnect'
    track twitter_account, event_name

    redirect_to project_twitter_accounts_path(@project),
      notice: "Your Twitter account #{ twitter_account.at_screen_name } has been connected."
  end

  # Handle failed omniauth authorization requests
  def failure
    redirect_to project_twitter_accounts_path(@project),
      alert: "Your Twitter account could not be connected."
  end

  private

  # Filter defined in ProjectController
  def load_and_authorize_project
    @project ||= user_projects.find(user_session.delete(:project_id))
    authorize @project, :access?

    @access_scope = user_session.delete(:access_scope)
  end
end
