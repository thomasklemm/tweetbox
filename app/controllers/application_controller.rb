class ApplicationController < ActionController::Base
  include ApplicationHelper
  include Pundit
  protect_from_forgery

  # Redirect user back on detected access violation
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Redirect the user to his main project after sign_in
  # if there is only one
  # TODO: Cache projects_count on users
  def after_sign_in_path_for(resource)
    projects_path
  end

  def after_sign_out_path_for(resource_or_scope)
    root_url
  end

  # Returns the decorated current_user
  def current_user
    UserDecorator.decorate(super) unless super.nil?
  end

  private

  # Handle user access violations
  # to actions his access level does not permit
  # detected by pundit
  def user_not_authorized
    flash[:error] = "You are not authorized to perform this action."
    redirect_to request.headers["Referer"] || root_path
  end

  helper_method :user_account, :user_projects, :user_project

  def user_account
    @user_account ||= current_user.account
  end

  def user_projects
    @user_projects ||= current_user.projects
  end

  def user_project
    @user_project ||= user_projects.find(params[:project_id] || params[:id])
  end
end
