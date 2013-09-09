# AccountTracker.new(@account, user).track_create

class AccountTracker < BaseTracker
  def initialize(account, user)
    @account = account
    @user = user
  end
  attr_reader :account, :user

  def track_create
    track_create_event
    set_properties_on_account
  end

  private

  def track_create_event
    tracker.track(user.mixpanel_id, 'Account Create', {
      '$username' => account.name,
      'Name'      => account.name
    })
  end

  def set_properties_on_account
    tracker.people.set(account.mixpanel_id, {
      'Type'               => 'Account',
      '$username'          => account.name,
      'Name'               => account.name,
      '$created'           => account.created_at.iso8601,
      'Number of Users'    => account.users.count,
      'Number of Projects' => account.projects.count
    })
  end
end
