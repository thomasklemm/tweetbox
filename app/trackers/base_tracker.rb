class BaseTracker
  def tracker
    @tracker ||= Mixpanel::Tracker.new(ENV['MIXPANEL_PROJECT_TOKEN'])
  end
end
