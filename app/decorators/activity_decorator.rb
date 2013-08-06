class ActivityDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all

  alias_method :activity, :model

  def render_activity
    div_for activity do
      concat time_ago_in_words(activity.created_at) + ": "
      concat link_to(activity.user.name, [:dash, activity.user]) + " "
      concat render_partial
    end
  end

  def render_partial
    locals = {activity: activity, presenter: self}
    locals[activity.trackable_type.underscore.to_sym] = activity.trackable
    render partial_path, locals
  end

  def partial_path
    partial_paths.detect do |path|
      lookup_context.template_exists? path, nil, true
    end || raise("No partial found for #{ activity } in #{partial_paths}")
  end

  def partial_paths
    [
      "dash/activities/#{activity.trackable_type.underscore}/#{activity.action}",
      "dash/activities/#{activity.trackable_type.underscore}",
      "dash/activities/activity"
    ]
  end
end
