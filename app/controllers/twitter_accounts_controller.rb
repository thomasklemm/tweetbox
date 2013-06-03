class TwitterAccountsController < ProjectController
  ACCESS_SCOPE_WRITE_PATH = '/auth/twitter?use_authorize=true&force_login=true'
  ACCESS_SCOPE_READ_PATH  = '/auth/twitter?use_authorize=true&x_auth_access_type=read&force_login=true'

  before_filter :load_twitter_account, only: [:show, :destroy, :default]

  def index
    @twitter_accounts = project_twitter_accounts
  end

  def show
  end

  def new
  end

  def destroy
    @twitter_account.destroyable? or return redirect_to :back,
      alert: "Twitter account could not be removed due to restrictions."

    @twitter_account.destroy
    redirect_to project_twitter_accounts_path(@project),
      notice: "Twitter account has been removed."
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

  # Set the project's default twitter account
  def default
    @twitter_account.default!
    redirect_to project_twitter_accounts_path(@project), notice: "Twitter account has been set as the project's default Twitter account."
  end

  private

  def project_twitter_accounts
    @project.twitter_accounts
  end

  def project_twitter_account
    project_twitter_accounts.find(params[:id])
  end

  def load_twitter_account
    @twitter_account = project_twitter_account
  end
end
