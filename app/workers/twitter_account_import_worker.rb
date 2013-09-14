# TwitterAccountImportWorker
#
# Imports that most recent 100 mentions
#   and the entire user timeline
#   to build up initial data for the project
#   and a history of conversations with customers
#
class TwitterAccountImportWorker
  include Sidekiq::Worker
  sidekiq_options backtrace: true

  def perform(twitter_account_id)
    @twitter_account = TwitterAccount.find(twitter_account_id)

    # Schedule queries for the first twenty minutes after connecting a Twitter account
    Scheduler.schedule_initial_timeline_queries(@twitter_account)

    fetch_mentions_timeline
    fetch_user_timeline

    # Set timestamp
    @twitter_account.touch(:imported_at)
  end

  private

  # Fetch the most recent 100 mentions
  # and mark them as :incoming
  # Should give great first data pretty quickly
  # to work with in Tweetbox
  def fetch_mentions_timeline
    statuses = @twitter_account.client.mentions_timeline(count: 100)
    TweetMaker.many_from_twitter(statuses,
      project: @twitter_account.project,
      twitter_account: @twitter_account,
      state: :incoming)
  end

  # Fetch the user's tweets as far as they reach back,
  # up to 3,200 tweets can be retrieved through the Twitter user_timeline API.
  # Mark them as posted outside
  # Involves fetching the conversation for each reply
  # Helps build up conversations of our customer with our customer's customers
  def fetch_user_timeline(max_id=nil)
    options = { count: 200 }
    options[:max_id] = max_id if max_id.present?

    statuses = @twitter_account.client.user_timeline(options)
    TweetMaker.many_from_twitter(statuses,
      project: @twitter_account.project,
      twitter_account: @twitter_account,
      state: :posted)

    # Run loop if current request returned some results
    if statuses.present?
      # On Twitter API options:
      #   max_id includes the tweet with id: max_id in the results (inclusive parameter),
      #   while since_id is does not (exclusive parameter)
      #
      # Unless -1 would be deducted, the method would call itself indefinitely
      # as the last tweet would always be returned as a single tweet
      # In addition, min_id - 1 helps avoid fetching duplicate results
      current_min_id = statuses.map(&:id).min
      next_run_max_id = current_min_id.try(:-, 1)

      # Loop
      fetch_user_timeline(next_run_max_id)
    end

  # Retry on all (and random) Twitter errors
  # though random failures should be more of an issue here
  # than rate limiting
  rescue Twitter::Error => e
    @runs ||= 0 and @runs += 1
    raise e if @runs > 3
    sleep 30 and retry
  end

end
