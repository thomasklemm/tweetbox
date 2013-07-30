class Dash::ApplicationController < ActionController::Base
  include Pundit

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Ensure that the current user is an admin
  # Raise Pundit::NotAuthorizedError otherwise
  before_action :authenticate_user!
  before_action :ensure_admin!

  # Dash layout
  layout 'dash/layouts/application'

  # Redirect user back on detected access violation
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Returns the decorated current_user
  def current_user
    UserDecorator.decorate(super) unless super.nil?
  end

  private

  def ensure_admin!
    raise Pundit::NotAuthorizedError unless current_user.admin?
  end

  def user_not_authorized
    flash[:error] = "You are not authorized to perform this action."
    redirect_to root_url
  end
end
