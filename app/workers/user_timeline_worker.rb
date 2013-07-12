class UserTimelineWorker
  include Sidekiq::Worker

  def perform(twitter_account_id)
    @twitter_account = TwitterAccount.find(twitter_account_id)
    @twitter_account.fetch_user_timeline

  # Twitter account could have been removed since scheduling
  rescue ActiveRecord::RecordNotFound
    false
  end
end
