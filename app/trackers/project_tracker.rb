# ProjectTracker.new(@project, user).track_create
# ProjectTracker.new(@project, user).track_update

class ProjectTracker < BaseTracker
  def initialize(project, user)
    @project = project
    @user = user
  end
  attr_reader :project, :user

  def track_create
    track_create_event
    set_properties_on_project
  end

  def track_update
    track_update_event
    set_properties_on_project
  end

  private

  def track_create_event
    tracker.track(user.mixpanel_id, 'Project Create', {
      'name':       project.name,
      'project_id': project.mixpanel_id,
      'account_id': project.account_mixpanel_id
    })
  end

  def track_update_event
    tracker.track(user.mixpanel_id, 'Project Update', {
      'name':       project.name,
      'project_id': project.mixpanel_id,
      'account_id': project.account_mixpanel_id
    })
  end

  def set_properties_on_project
    tracker.people.set(project.mixpanel_id, {
      'type':       'Project',
      'name':        project.name
      'account_id':  project.account_mixpanel_id,
      'created_on':  project.created_at.to_date
    })
  end
end
