class TwitterAccountsController < ProjectController
  AUTH_DIRECT_MESSAGES_PATH = '/auth/twitter?use_authorize=true'
  AUTH_READ_AND_WRITE_PATH  = '/auth/twitter?use_authorize=true&x_auth_access_type=write'
  AUTH_READ_PATH            = '/auth/twitter?use_authorize=true&x_auth_access_type=read'

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
    flash.notice = "Twitter account '@#{ @twitter_account.screen_name }' has been removed."
  rescue ActiveRecord::DeleteRestrictionError
    flash.alert = "Twitter account '@#{ @twitter_account.screen_name }' has not been removed because there are still search records that depend on it. Please edit these searches to use another Twitter account or remove them first."
  ensure
    redirect_to project_twitter_accounts_path(@project)
  end

  def toggle_mentions
    @twitter_account = project_twitter_account
    @twitter_account.get_mentions = !@twitter_account.get_mentions
    @twitter_account.save!
    redirect_to project_twitter_accounts_path(@project)
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

  def project_twitter_account
    project_twitter_accounts.find(params[:id])
  end
end
