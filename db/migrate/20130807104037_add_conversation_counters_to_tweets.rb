class AddConversationCountersToTweets < ActiveRecord::Migration
  def change
    add_column :tweets, :previous_tweets_count, :integer, default: 0
    add_column :tweets, :future_tweets_count, :integer, default: 0
  end
end
