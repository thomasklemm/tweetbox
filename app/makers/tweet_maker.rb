# Creates and returns tweet records
class TweetMaker
  # Returns an array of the persisted tweet records
  def self.many_from_twitter(statuses, opts={})
    statuses.map { |status| from_twitter(status, opts) }
  end

  # Returns the persisted tweet record
  def self.from_twitter(status, opts={})
    project = opts.fetch(:project) { raise 'Requires a :project' }
    twitter_account = opts.fetch(:twitter_account, nil)
    state = opts.fetch(:state) { raise 'Requires a :state' }

    # Find or initialize tweet
    tweet = project.tweets.where(twitter_id: status.id).first_or_initialize

    # Assign author and twitter account
    # Keep Twitter account if already present when building conversation
    tweet.author ||= AuthorMaker.from_twitter(status.user, project: project)
    tweet.twitter_account ||= twitter_account

    # Assign fields and state
    tweet.assign_fields(status)
    tweet.assign_state(state)

    # Persist tweet in the database
    # Return tweet
    tweet.save! and tweet

  rescue ActiveRecord::RecordNotUnique
    retry
  end
end
