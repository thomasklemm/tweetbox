# TweetFinder
#
# Finds or fetches a tweet with a given twitter_id in the context
#  of a given project
#
class TweetFinder
  def initialize(project, twitter_id)
    @project = project
    @twitter_id = twitter_id
  end

  # Returns a tweet record
  def find_or_fetch
    find_tweet || fetch_tweet
  end

  private

  # Returns the tweet record from the database if present
  def find_tweet
    @project.tweets.where(twitter_id: @twitter_id).first
  end

  # Fetches the given status from Twitter
  # Returns the persisted tweet record
  def fetch_tweet
    status = twitter_client.status(@twitter_id)

    # Avoid referencing random twitter account
    tweet = TweetMaker.from_twitter(status, project: @project, state: :conversation)

  rescue Twitter::Error => e
    @runs ||= 0 and @runs += 1

    # Statuses may be deleted voluntarily by the author
    if e.is_a? Twitter::Error::NotFound
      return nil if @runs > 2
    else
      raise e if @runs > 5
    end

    # Retry using a different random Twitter account
    sleep 0.5 and retry
  end

  # Instantiates a Twitter client from a random Twitter account in the database
  # that can only perform white-listed read-only actions on the Twitter API
  def twitter_client
    RandomTwitterClient.new
  end
end

