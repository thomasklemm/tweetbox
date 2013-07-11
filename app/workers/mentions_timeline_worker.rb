class MentionsTimelineWorker
  include Sidekiq::Worker

  def perform(twitter_account_id)
    @twitter_account = TwitterAccount.find(twitter_account_id)
    statuses = @twitter_account.client.mentions_timeline(timeline_options)
    tweets = Tweet.many_from_twitter(statuses, project: @twitter_account.project, twitter_account: @twitter_account, state: :incoming)
    @twitter_account.update_max_mentions_timeline_twitter_id(tweets.map(&:twitter_id).max)
    true
  rescue Twitter::Error
    false
  end

  private

  def timeline_options
    since_id = @twitter_account.max_mentions_timeline_twitter_id

    options = { count: 200 } # Max is 200
    options[:since_id] = since_id if since_id.present?
    options
  end
end
