# SearchTracker.new(@search, user).track_create
# SearchTracker.new(@search, user).track_update
# SearchTracker.new(@search, user).track_destroy

class SearchTracker < BaseTracker
  def initialize(search, user)
    @search = search
    @user = user
  end
  attr_reader :search, :user

  def track_create
    track_create_event
    set_properties_on_search
    set_searches_count_on_account
    set_searches_count_on_project
  end

  def track_update
    track_update_event
    set_properties_on_search
    increment_revisions_count_on_search
  end

  def track_destroy
    track_destroy_event
    set_destroyed_properties_on_search
    decrement_searches_count_on_account
    decrement_searches_count_on_project
  end

  private

  delegate :account, :project, :twitter_account, to: :search

  def event_hash
    {
      'Query'              => search.query,
      'Project Id'         => project.mixpanel_id,
      'Project Name'       => project.name,
      'Account Id'         => account.mixpanel_id,
      'Account Name'       => account.name,
      'Twitter Account Id' => twitter_account.mixpanel_id,
      'Twitter Account'    => twitter_account.at_screen_name
    }
  end

  ##
  # Create and Update

  def track_create_event
    tracker.track(user.mixpanel_id, 'Search Create', event_hash)
  end

  # TODO: Track old and new query to see what changes
  #       and provide advice and insights to people
  def track_update_event
    tracker.track(user.mixpanel_id, 'Search Update', event_hash)
  end

  def set_properties_on_search
    tracker.people.set(search.mixpanel_id, {
      'Type'               => 'Search',
      'Query'              => search.query,
      '$created'           => search.created_at.iso8601,
      'Project Id'         => project.mixpanel_id,
      'Project Name'       => project.name,
      'Account Id'         => account.mixpanel_id,
      'Account Name'       => account.name,
      'Twitter Account Id' => twitter_account.mixpanel_id,
      'Twitter Account'    => twitter_account.at_screen_name,
      'Active'             => true
    })
  end

  def set_searches_count_on_account
    tracker.people.set(account.mixpanel_id, {
      'Number of Searches Count' => account.searches.count
    })
  end

  def set_searches_count_on_project
    tracker.people.set(project.mixpanel_id, {
      'Number of Searches Count' => project.searches.count
    })
  end

  def increment_revisions_count_on_search
    tracker.people.increment(search.mixpanel_id, {
      'Number of Revisions' => 1
    })
  end

  ##
  # Destroy

  def track_destroy_event
    tracker.track(user.mixpanel_id, 'Search Destroy', event_hash)
  end

  def set_destroyed_properties_on_search
    tracker.people.set(search.mixpanel_id, {
      'Active'       => false,
      'Destroyed At' => Time.current.iso8601
    })
  end
end
