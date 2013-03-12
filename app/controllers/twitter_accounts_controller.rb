class TwitterAccountsController < ProjectController
  AUTH_DIRECT_MESSAGES_PATH = '/auth/twitter?use_authorize=true'
  AUTH_READ_AND_WRITE_PATH  = '/auth/twitter?use_authorize=true&x_auth_access_type=write'
  AUTH_READ_PATH            = '/auth/twitter?use_authorize=true&x_auth_access_type=read'

  def index
    @twitter_accounts = project_twitter_accounts
  end

  def show
    @twitter_account = project_twitter_accounts.find(params[:id])
  end

  def new
  end

  # Redirect to twitter authorization path
  def auth
    user_session[:project_id] = @project.id

    case params[:auth_scope].to_s
      when 'direct_messages'
        user_session[:twitter_auth_scope] = :direct_messages
        return redirect_to AUTH_DIRECT_MESSAGES_PATH
      when 'read_and_write'
        user_session[:twitter_auth_scope] = :read_and_write
        return redirect_to AUTH_READ_AND_WRITE_PATH
      when 'read'
        user_session[:twitter_auth_scope] = :read
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
end
