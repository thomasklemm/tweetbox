# UserTracker.new(@user).track_create_by_signup
# UserTracker.new(@user).track_create_by_invitation

class UserTracker < BaseTracker
  def initialize(user)
    @user = user
  end
  attr_reader :user

  delegate :account, to: :user

  def track_create_by_signup
    track_create_event('Signup')
    set_properties_on_user('Signup')
    set_users_count_on_account
    set_users_count_on_projects
  end

  def track_create_by_invitation
    track_create_event('Invitation')
    set_properties_on_user('Invitation')
    set_users_count_on_account
    set_users_count_on_projects
  end

  private

  def track_create_event(reason)
    tracker.track(user.mixpanel_id, 'User Create', {
      '$username'    => "User: #{user.full_name}",
      '$first_name'  => user.first_name,
      '$last_name'   => user.last_name,
      '$email'       => user.email,
      'Account Id'   => account.mixpanel_id,
      'Account Name' => account.name,
      'Reason'       => reason
    })
  end

  def set_properties_on_user(reason)
    tracker.people.set(user.mixpanel_id, {
      'Type'         => 'User',
      '$username'    => "User: #{user.full_name}",
      '$first_name'  => user.first_name,
      '$last_name'   => user.last_name,
      '$email'       => user.email,
      '$created'     => user.created_at.iso8601,
      'Account Id'   => account.mixpanel_id,
      'Account Name' => account.name
    })

    tracker.people.set_once(user.mixpanel_id, {
      'Reason' => reason
    })
  end

  def set_users_count_on_account
    tracker.people.set(account.mixpanel_id, {
      'Number of Users' => account.users.count
    })
  end

  def set_users_count_on_projects
    user.projects.each do |project|
      tracker.people.set(project.mixpanel_id, {
        'Number of Users' => project.users.count
      })
    end
  end
end
