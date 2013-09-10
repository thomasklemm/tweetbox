# ProjectTracker.new(@project, user).track_create
# ProjectTracker.new(@project, user).track_update

class ProjectTracker < BaseTracker
  def initialize(project, user)
    @project = project
    @user = user
  end
  attr_reader :project, :user

  delegate :account, to: :project

  def track_create
    track_create_event
    set_properties_on_project
    set_projects_count_on_account
  end

  def track_update
    track_update_event
    set_properties_on_project
  end

  private

  def event_hash
    {
      '$username'  => "Project: #{project.name}",
      'Name'       => project.name,
      'Project Id' => project.mixpanel_id,
      'Account Id' => account.mixpanel_id
    }
  end

  def track_create_event
    tracker.track(user.mixpanel_id, 'Project Create', event_hash)
  end

  def track_update_event
    tracker.track(user.mixpanel_id, 'Project Update', event_hash)
  end

  def set_properties_on_project
    tracker.people.set(project.mixpanel_id, {
      'Type'            => 'Project',
      '$username'       => "Project: #{project.name}",
      'Name'            => project.name,
      'Account Id'      => account.mixpanel_id,
      'Account Name'    => account.name,
      '$created'        => project.created_at.iso8601,
      'Number of Users' => project.users.count
    })
  end

  def set_projects_count_on_account
    tracker.people.set(account.mixpanel_id, {
      'Number of Projects' => account.projects.count
    })
  end
end
