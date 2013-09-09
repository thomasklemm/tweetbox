# UserTracker.new(@user, reason = 'Signup' / 'Invitation').track_create
# UserTracker.new(@user).set_last_seen_at_to_current_time

class UserTracker < BaseTracker
  def initialize(user, reason)
    @user = user
    @reason = reason
  end
  attr_reader :user, :reason

  def track_create
    track_create_event
    set_properties_on_user
  end

  # NOTE: This avoids a lot of events
  #       and just uses the people API, right?
  def set_last_seen_at_to_current_time
    tracker.people.set(user.mixpanel_id, {
      'last seen at': Time.current
    })
  end

  private

  def track_create_event
    tracker.track(user.mixpanel_id, 'User Create', {
      'name':         user.name,
      'email':        user.email,
      'reason':       reason,
      'account_id':   user.account_mixpanel_id,
      'account name': user.account.name
    })
  end

  def set_properties_on_user
    tracker.people.set(user.mixpanel_id, {
      'name':         user.name,
      'email':        user.email,
      'account_id':   user.account_mixpanel_id,
      'account name': user.account.name,
      'created on':   user.created_at.to_date
    })

    tracker.people.set_once(user.mixpanel_id, {
      'reason': reason
    })
  end
end
