class TwitterAccountsController < ProjectController
  ACCESS_SCOPE_WRITE_PATH = '/auth/twitter?use_authorize=true&force_login=true'
  ACCESS_SCOPE_READ_PATH  = '/auth/twitter?use_authorize=true&x_auth_access_type=read&force_login=true'

  before_filter :load_twitter_account, only: [:set_default, :destroy]

  ##
  # Collection actions

  def index
    @twitter_accounts = project_twitter_accounts.decorate
  end

  def new
  end

  # Redirect to twitter authorization path
  #   authorize_project_twitter_accounts_path(@project, access_scope: 'write')
  def auth
    access_scope = params[:access_scope]
    TwitterAccount::ACCESS_SCOPES.include?(access_scope) or
      return redirect_to :back, notice: "Please provide a valid access scope for the new Twitter account."

    user_session[:project_id] = @project.id
    user_session[:access_scope] = access_scope

    case access_scope
    when 'write' then return redirect_to ACCESS_SCOPE_WRITE_PATH
    when 'read'  then return redirect_to ACCESS_SCOPE_READ_PATH
    else raise ''
    end
  end

  ##
  # Member actions

  # Set the project's default twitter account
  def set_default
    @project.set_default_twitter_account(@twitter_account)
    redirect_to project_twitter_accounts_path(@project),
      notice: "#{ @twitter_account.at_screen_name } is now the project's default Twitter account."
  end

  def destroy
    @twitter_account.searches.any? and return redirect_to project_twitter_accounts_path(@project),
      alert: "#{ @twitter_account.at_screen_name } could not be removed. There are searches that
      depend on being performed through the #{ @twitter_account.at_screen_name } Twitter account.
      Please remove these search queries first or update them to use another Twitter account."

    if @twitter_account.destroy
      TwitterAccountTracker.new(@twitter_account, current_user).track_destroy
      flash.notice = "Twitter account #{ @twitter_account.at_screen_name } has been removed from Tweetbox."
    else
      flash.notice = "#{ @twitter_account.at_screen_name } could not be removed."
    end

    redirect_to project_twitter_accounts_path(@project)
  end

  private

  def project_twitter_accounts
    @project.twitter_accounts
  end

  def project_twitter_account
    project_twitter_accounts.find(params[:id])
  end

  def load_twitter_account
    @twitter_account = project_twitter_account.decorate
  end
end
