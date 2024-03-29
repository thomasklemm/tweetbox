# MentionsTimelineWorker
#
# Fetches the mentions timeline of a given Twitter account
#
class MentionsTimelineWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, backtrace: true

  def perform(twitter_account_id, perform_at)
    return if expired?(perform_at)

    @twitter_account = TwitterAccount.find(twitter_account_id)
    @twitter_account.fetch_mentions_timeline

  # Twitter account could have been removed since scheduling
  rescue ActiveRecord::RecordNotFound
    true
  end

  private

  def expired?(perform_at)
    perform_at < 90.seconds.ago
  end
end
