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
    set_twitter_accounts_count_on_account
    set_twitter_accounts_count_on_project
  end

  def track_update
    track_update_event
    set_properties_on_twitter_account
  end

  def track_destroy
    track_destroy_event
    set_destroyed_properties_on_twitter_account
    set_twitter_accounts_count_on_account
    set_twitter_accounts_count_on_project
  end

  private

  delegate :account, :project, to: :twitter_account

  ##
  # Create and Update

  def event_hash
    {
      '$username'          => twitter_account.at_screen_name,
      'Screen Name'        => twitter_account.screen_name,
      'Name'               => twitter_account.name,
      'Twitter Id'         => twitter_account.twitter_id,
      'Twitter Account Id' => twitter_account.mixpanel_id,
      'Project Id'         => project.mixpanel_id,
      'Project Name'       => project.name,
      'Account Id'         => account.mixpanel_id,
      'Account Name'       => account.name
    }
  end

  def track_create_event
    tracker.track(user.mixpanel_id, 'Twitter Account Create', event_hash)
  end

  def track_update_event
    tracker.track(user.mixpanel_id, 'Twitter Account Update', event_hash)
  end

  # TODO: Keep the properties up to date by fetching them from Twitter
  #       and posting them directly to Mixpanel in a recurring background worker job
  def set_properties_on_twitter_account
    tracker.people.set(twitter_account.mixpanel_id, {
      'Type'               => 'Twitter Account',
      '$username'          => twitter_account.at_screen_name,
      'Screen Name'        => twitter_account.screen_name,
      'Name'               => twitter_account.name,
      '$created'           => Time.current.iso8601,
      'Twitter Id'         => twitter_account.twitter_id,
      'Twitter Account Id' => twitter_account.mixpanel_id,
      'Project Id'         => project.mixpanel_id,
      'Project Name'       => project.name,
      'Account Id'         => account.mixpanel_id,
      'Account Name'       => account.name
      'Active'             => true
    })

    tracker.people.set_once(twitter_account.mixpanel_id, {
      'Connected At' => Time.current.iso8601
    })
  end

  def set_twitter_accounts_count_on_account
    tracker.people.set(account.mixpanel_id, {
      'Number of Twitter Accounts' => account.twitter_accounts.count
    })
  end

  def set_twitter_accounts_count_on_project
    tracker.people.set(project.mixpanel_id, {
      'Number of Twitter Accounts' => project.twitter_accounts.count
    })
  end

  ##
  # Destroy

  def track_destroy_event
    tracker.track(user.mixpanel_id, 'Twitter Account Destroy', event_hash)
  end

  def set_destroyed_properties_on_twitter_account
    tracker.people.set(twitter_account.mixpanel_id, {
      'Active'       => false,
      'Destroyed At' => Time.current.iso8601
    })
  end
end
