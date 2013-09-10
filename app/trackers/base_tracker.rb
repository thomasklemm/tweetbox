class BaseTracker
  def tracker
    return NullTracker.new if Rails.env.test?
    @tracker ||= Mixpanel::Tracker.new(ENV['MIXPANEL_PROJECT_TOKEN'])
  end
end
