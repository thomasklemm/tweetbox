class TwitterAccountsController < ProjectController
  AUTH_READ_AND_WRITE_AND_MESSAGES_PATH = '/auth/twitter?use_authorize=true&force_login=true'
  AUTH_READ_AND_WRITE_PATH  = '/auth/twitter?use_authorize=true&x_auth_access_type=write&force_login=true'
  AUTH_READ_PATH  = '/auth/twitter?use_authorize=true&x_auth_access_type=read&force_login=true'

  def index
    @twitter_accounts = project_twitter_accounts
  end

  def show
    @twitter_account = project_twitter_account
  end

  def new
  end

  def destroy
    @twitter_account = project_twitter_account
    @twitter_account.destroy
    flash.notice = "Twitter account #{ @twitter_account.at_screen_name } has been removed."
  rescue ActiveRecord::DeleteRestrictionError
    flash.alert = "Twitter account #{ @twitter_account.at_screen_name } has not been removed because there are still search records that depend on it. Please edit these searches to use another Twitter account or remove them first."
  ensure
    redirect_to project_twitter_accounts_path(@project)
  end

  # Redirect to twitter authorization path
  def auth
    user_session[:project_id] = @project.id
    user_session[:twitter_authorize_for] = params[:authorize_for]

    case params[:authorize_for].to_s
    when 'read_and_write_and_messages'
      return redirect_to AUTH_READ_AND_WRITE_AND_MESSAGES_PATH
    when 'read_and_write'
      return redirect_to AUTH_READ_AND_WRITE_PATH
    when 'read'
      return redirect_to AUTH_READ_PATH
    else
      user_session.delete(:project_id)
      flash[:notice] = "Please provide a valid authorization scope."
      redirect_to project_twitter_accounts_path
    end
  end

  private

  def project_twitter_accounts
    @project.twitter_accounts
  end

  def project_twitter_account
    project_twitter_accounts.find(params[:id])
  end
end
