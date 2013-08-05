class ApplicationController < ActionController::Base
  include ApplicationHelper
  include Pundit

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Redirect user back on detected access violation
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Update last_seen_at timestamp on user
  before_action :update_last_seen_at!

  # Returns the decorated current_user
  def current_user
    UserDecorator.decorate(super) unless super.nil?
  end

  private

  def user_not_authorized
    flash[:error] = "You are not authorized to perform this action."
    redirect_to request.headers["Referer"] || root_url
  end

  # Updates the last seen at timestamp on the user periodically
  def update_last_seen_at!
    return unless user_signed_in?

    # nil.to_i => 0
    if current_user.last_seen_at.to_i < 5.minutes.ago.to_i
      current_user.touch(:last_seen_at)
    end
  end

  # Devise paths
  def after_sign_in_path_for(resource)
    current_user.has_exactly_one_project? ? current_user.first_project_path : projects_path
  end

  def after_sign_out_path_for(resource_or_scope)
    root_url
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
