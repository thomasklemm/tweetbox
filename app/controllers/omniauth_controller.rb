class OmniauthController < ProjectController
  skip_before_filter :load_and_authorize_project
  before_filter :load_project

  # Handle the omniauth callback from Twitter
  def twitter
    auth = request.env['omniauth.auth']
    # Create or update twitter account
    twitter_account = TwitterAccount.from_omniauth(@project, auth, @access_scope)

    redirect_to project_twitter_accounts_path(@project),
      notice: "Your Twitter account #{ twitter_account.at_screen_name } has been connected."
  end

  # Handle failed omniauth authorization requests
  def failure
    redirect_to project_twitter_accounts_path(@project),
      alert: "Your Twitter account could not be connected."
  end

  private

  # FIXME: Matching name
  def load_project
    @project_id = user_session.delete(:project_id)
    @project ||= user_project.find(@project_id)
    authorize @project, :access?

    @access_scope = user_session.delete(:access_scope)
  end
end
