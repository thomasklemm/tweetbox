class MentionsTimelineWorker
  include Sidekiq::Worker

  def perform(twitter_account_id, perform_at)
    return if expired?(perform_at)

    @twitter_account = TwitterAccount.find(twitter_account_id)
    @twitter_account.fetch_mentions_timeline

  # Twitter account could have been removed since scheduling
  rescue ActiveRecord::RecordNotFound
    false
  end

  private

  def expired?(perform_at)
    perform_at < 90.seconds.ago
  end
end
