class MentionsTimelineWorker
  include Sidekiq::Worker

  def perform(twitter_account_id, scheduled_for)
    return if expired?(scheduled_for)

    @twitter_account = TwitterAccount.find(twitter_account_id)
    @twitter_account.fetch_mentions_timeline

  # Twitter account could have been removed since scheduling
  rescue ActiveRecord::RecordNotFound
    false
  end

  private

  # Expire jobs 90 seconds after their scheduled_for timestamp
  def expired?(scheduled_for)
    scheduled_for < 90.seconds.ago
  end
end
