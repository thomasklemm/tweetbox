class MovePreviousTweetsToConversation < ActiveRecord::Migration
  def up
    Tweet.find_each do |tweet|
      twitter_ids = tweet[:previous_tweet_ids]
      # Skip if there are no previous tweet ids
      next unless twitter_ids.present?

      twitter_ids.each do |twitter_id|
        previous_tweet = Tweet.find_by!(project: tweet.project, twitter_id: twitter_id)
        tweet.previous_tweets |= [previous_tweet]
        puts "#{ tweet } has #{ tweet.previous_tweets.count } / #{ tweet.previous_tweets_count } previous tweets."
      end
    end

    # Reset counters
    Tweet.find_each do |tweet|
      Tweet.reset_counters(tweet.id, :previous_tweets, :future_tweets)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'one way only'
  end
end
