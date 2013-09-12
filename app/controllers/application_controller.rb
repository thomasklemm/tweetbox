class ApplicationController < ActionController::Base
  include ApplicationHelper
  include Pundit

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Enable miniprofiler for staff members in production
  before_action :miniprofiler

  # Redirect user back on detected access violation
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  # Handle user access violations
  def user_not_authorized
    flash[:error] = "You are not authorized to perform this action."
    redirect_to request.headers["Referer"] || root_url
  end

  # Enable miniprofiler for staff members in production
  def miniprofiler
    Rack::MiniProfiler.authorize_request if current_user && current_user.staff_member?
  end

  ##
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

  ##
  # Event tracking

  helper_method :track, :track_user

  # track 'Project Create', @project, { 'Name' => @project.name }
  def track(event_name, eventable=nil, properties={})
    event = Event.create!(name: event_name, eventable: eventable, user: current_user)

    properties.reverse_merge!(
      'Event Id'  => event.id,
      'Event URL' => dash_event_url(event)
    )

    properties.reverse_merge!(eventable.mixpanel_hash) if eventable.respond_to?(:mixpanel_hash)

    mixpanel_tracker.track(current_user.mixpanel_id, event_name, properties) unless Rails.env.test?
  end

  # track_user @signup.user, nil / 'Signup' / 'Invitation'
  def track_user(user=current_user, source=nil)
    return if Rails.env.test?

    mixpanel_tracker.people.set(user.mixpanel_id, {
      '$first_name'  => user.first_name,
      '$last_name'   => user.last_name,
      '$email'       => user.email,
      '$created'     => user.created_at.iso8601,
      'User URL'     => dash_user_url(user),
      'Account Name' => user.account.name,
      'Account URL'  => dash_account_url(user.account)
    })

    mixpanel_tracker.people.set_once(user.mixpanel_id, { 'Signup Source' => source }) if source
  end

  def mixpanel_tracker
    @mixpanel_tracker ||= Mixpanel::Tracker.new(ENV['MIXPANEL_PROJECT_TOKEN'])
  end

  ##
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
end
