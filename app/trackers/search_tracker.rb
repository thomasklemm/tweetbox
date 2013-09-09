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
    increment_searches_count_on_account
    increment_searches_count_on_project
  end

  def track_update
    track_update_event
    set_properties_on_search
  end

  def track_destroy
    track_destroy_event
    set_destroyed_properties_on_search
    decrement_searches_count_on_account
    decrement_searches_count_on_project
  end

  private

  ##
  # Create and Update

  def track_create_event
    tracker.track(user.mixpanel_id, 'Search Create', {
      'query'              => search.query,
      'project_id'         => search.project_mixpanel_id,
      'account_id'         => search.account_mixpanel_id,
      'twitter_account_id' => search.twitter_account_mixpanel_id
    })
  end

  # TODO: Track old and new query to see what changes
  #       and provide advice and insights to people
  def track_update_event
    tracker.track(user.mixpanel_id, 'Search Update', {
      'query'              => search.query,
      'project_id'         => search.project_mixpanel_id,
      'account_id'         => search.account_mixpanel_id,
      'twitter_account_id' => search.twitter_account_mixpanel_id
    })
  end

  def set_properties_on_search
    tracker.people.set(search.mixpanel_id, {
      'type'            => 'Search',
      'account_id'      => search.account_mixpanel_id,
      'project_id'      => search.project_mixpanel_id,
      'query'           => search.query,
      'twitter account' => search.twitter_account.screen_name
    })

    tracker.people.set_once(search.mixpanel_id, {
      'first created on' => Date.current
    })
  end

  def increment_searches_count_on_account
    tracker.people.increment(search.account_mixpanel_id, {
      'Searches Count' => 1
    })
  end

  def increment_searches_count_on_project
    tracker.people.increment(search.project_mixpanel_id, {
      'Searches Count' => 1
    })
  end

  ##
  # Destroy

  def track_destroy_event
    tracker.track(user.mixpanel_id, 'Search Destroy', {
      'query'              => search.query,
      'project_id'         => search.project_mixpanel_id,
      'account_id'         => search.account_mixpanel_id,
      'twitter_account_id' => search.twitter_account_mixpanel_id
    })
  end

  def set_destroyed_properties_on_search
    tracker.people.set(search.mixpanel_id, {
      'active'       => false,
      'destroyed on' => Date.current
    })
  end

  def decrement_searches_count_on_account
    tracker.people.increment(search.account_mixpanel_id, {
      'Searches Count' => -1
    })
  end

  def decrement_searches_count_on_project
    tracker.people.increment(search.project_mixpanel_id, {
      'Searchs Count' => -1
    })
  end
end
