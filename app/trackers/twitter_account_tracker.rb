# TwitterAccountTracker.new(@twitter_account, user).track_create
# TwitterAccountTracker.new(@twitter_account, user).track_update
# TwitterAccountTracker.new(@twitter_account, user).track_destroy

class TwitterAccountTracker < BaseTracker
  def initialize(twitter_account, user)
    @twitter_account = twitter_account
    @user = user
  end
  attr_reader :twitter_account, :user

  def track_create
    track_create_event
    set_properties_on_twitter_account
    increment_twitter_accounts_count_on_account
    increment_twitter_accounts_count_on_project
  end

  def track_update
    track_update_event
    set_properties_on_twitter_account
  end

  def track_destroy
    track_destroy_event
    set_destroyed_properties_on_twitter_account
    decrement_twitter_accounts_count_on_account
    decrement_twitter_accounts_count_on_project
  end

  private

  ##
  # Create and Update

  def track_create_event
    tracker.track(user.mixpanel_id, 'Twitter Account Create', {
      'twitter_account_id' => twitter_account.mixpanel_id,
      'twitter id'         => twitter_account.twitter_id,
      'screen name'        => twitter_account.screen_name,
      'name'               => twitter_account.name,
      'project_id'         => twitter_account.project_mixpanel_id,
      'account_id'         => twitter_account.account_mixpanel_id
    })
  end

  def track_update_event
    tracker.track(user.mixpanel_id, 'Twitter Account Update', {
      'twitter_account_id' => twitter_account.mixpanel_id,
      'twitter id'         => twitter_account.twitter_id,
      'screen name'        => twitter_account.screen_name,
      'name'               => twitter_account.name,
      'project_id'         => twitter_account.project_mixpanel_id,
      'account_id'         => twitter_account.account_mixpanel_id
    })
  end

  # TODO: Keep the properties up to date by fetching them from Twitter
  #       and posting them directly to Mixpanel in a recurring background worker job
  def set_properties_on_twitter_account
    tracker.people.set(twitter_account.mixpanel_id, {
      'type'        => 'Twitter Account',
      'twitter id'  => twitter_account.twitter_id,
      'screen name' => twitter_account.screen_name,
      'name'        => twitter_account.name,
      'project_id'  => twitter_account.project_mixpanel_id,
      'account_id'  => twitter_account.account_mixpanel_id
      'active'      => true
    })

    tracker.people.set_once(twitter_account.mixpanel_id, {
      'first connected to tweetbox on' => Date.current
    })
  end

  def increment_twitter_accounts_count_on_account
    tracker.people.increment(twitter_account.account_mixpanel_id, {
      'Twitter Accounts Count' => 1
    })
  end

  def increment_twitter_accounts_count_on_project
    tracker.people.increment(twitter_account.project_mixpanel_id, {
      'Twitter Accounts Count' => 1
    })
  end

  ##
  # Destroy

  def track_destroy_event
    tracker.track(user.mixpanel_id, 'Twitter Account Destroy', {
      'twitter_account_id' => twitter_account.mixpanel_id,
      'twitter id'         => twitter_account.twitter_id,
      'screen name'        => twitter_account.screen_name,
      'name'               => twitter_account.name,
      'project_id'         => twitter_account.project_mixpanel_id,
      'account_id'         => twitter_account.account_mixpanel_id
    })
  end

  def set_destroyed_properties_on_twitter_account
    tracker.people.set(twitter_account.mixpanel_id, {
      'active'       => false,
      'destroyed on' => Date.current
    })
  end

  def decrement_twitter_accounts_count_on_account
    tracker.people.increment(twitter_account.account_mixpanel_id, {
      'Twitter Accounts Count' => -1
    })
  end

  def decrement_twitter_accounts_count_on_project
    tracker.people.increment(twitter_account.project_mixpanel_id, {
      'Twitter Accounts Count' => -1
    })
  end
end
