class ApplicationController < ActionController::Base
  include ApplicationHelper
  include Pundit

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :miniprofiler

  # Redirect user back on detected access violation
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Returns the decorated current_user
  def current_user
    return if super.nil?
    @decorated_current_user ||= UserDecorator.decorate(super)
  end

  private

  def user_not_authorized
    flash[:error] = "You are not authorized to perform this action."
    redirect_to request.headers["Referer"] || root_url
  end

  # Enable MiniProfiler in production for staff members
  def miniprofiler
    Rack::MiniProfiler.authorize_request if current_user && current_user.staff_member?
  end

  # Devise paths
  def after_sign_in_path_for(resource)
    main_user_project_path
  end

  def after_sign_out_path_for(resource_or_scope)
    root_url
  end

  helper_method :main_user_project_path
  def main_user_project_path
    user_projects.any? ? project_path(user_projects.by_date.first) : root_path
  end

  # Activites
  def track_activity(trackable, action)
    current_user.activities.create!(action: action, trackable: trackable)
  end

  # Scopes
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
