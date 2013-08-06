class Dash::ApplicationController < ActionController::Base
  include Pundit

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Ensure that the current user is a staff member
  # Raise Pundit::NotAuthorizedError otherwise
  # Additional protection is provided by a StaffMemberConstraint in routes
  # before_action :authenticate_user!
  # before_action :ensure_staff_member!

  # Dash layout
  layout 'dash/layouts/application'

  # Redirect user back on detected access violation
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Returns the decorated current_user
  def current_user
    UserDecorator.decorate(super) unless super.nil?
  end

  private

  def ensure_staff_member!
    raise Pundit::NotAuthorizedError unless current_user.staff_member?
  end

  def user_not_authorized
    flash[:error] = "You are not authorized to perform this action."
    redirect_to root_url
  end
end
