# MixpanelWorker
#
# Tracks events in Mixpanel async
#
class MixpanelWorker
  include Sidekiq::Worker
  sidekiq_options backtrace: true

  def perform(distinct_id, event_name, properties)
    mixpanel_tracker.track(distinct_id, event_name, properties)
  end

  private

  def mixpanel_tracker
    @mixpanel_tracker ||= Mixpanel::Tracker.new(ENV['MIXPANEL_PROJECT_TOKEN'])
  end
end
