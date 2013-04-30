class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Redirect the user to his main project after sign_in
  # if there is only one
  def after_sign_in_path_for(resource)
    if current_user.projects.count == 1
      project_path(current_user.projects.first)
    else
      projects_path
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    root_url
  end

  private

  # Handle user access violations
  # to actions his access level does not permit
  # detected by pundit
  def user_not_authorized
    flash[:error] = "You are not authorized to access or perform this action."
    redirect_to :back
  end

  helper_method :user_accounts, :user_account
  helper_method :user_projects, :user_project

  def user_accounts
    accounts ||= current_user.accounts
  end

  def user_account
    @account ||= user_accounts.find(params[:account_id] || params[:id])
  end

  def user_projects
    projects ||= current_user.projects
  end

  def user_project
    @project ||= user_projects.find(params[:project_id] || user_session[:project_id] || params[:id])
  end
end
